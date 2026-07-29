// ============================================================================
// TailspinToys Azure Infrastructure - Bicep Template
// ============================================================================
// This template deploys a complete Azure App Service infrastructure with:
// - App Service Plan (shared compute)
// - App Service (web app)
// - Staging deployment slot (for blue-green deployments)
// - Application Insights (monitoring & diagnostics)
// ============================================================================

// Define the Azure region for all resources
param location string = resourceGroup().location

// App name used as the base for resource naming
param appName string = 'tailspintoys'

// Environment name (prod, staging, dev, etc.)
param environment string = 'prod'

// SKU for App Service Plan (B1, B2, S1, S2, P1V2, etc.)
param appServiceSku string = 'B2'

// ============================================================================
// VARIABLES - Derived names for consistent resource naming
// ============================================================================

// Combine app name and environment for unique resource naming
var uniqueName = '${appName}-${environment}'

// App Service Plan name
var appServicePlanName = '${uniqueName}-plan'

// App Service (Web App) name - must be globally unique across Azure
var webAppName = '${uniqueName}-${uniqueString(resourceGroup().id)}'

// Application Insights name
var appInsightsName = '${uniqueName}-insights'

// ============================================================================
// RESOURCE 1: App Service Plan
// ============================================================================
// The App Service Plan defines the compute resources (CPU, memory) that
// will host the web application. Think of it as a virtual server.
//
// - kind: 'Linux' means the OS is Linux (lightweight, cost-effective)
// - sku: specifies tier (B1=cheap/small, B2=medium, S1/S2=standard, P=premium)
// - reserved: true required for Linux App Service Plans
// ============================================================================

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  kind: 'Linux'
  sku: {
    name: appServiceSku
    capacity: 1  // Number of instances
  }
  properties: {
    reserved: true  // Required for Linux
  }
  tags: {
    environment: environment
    application: appName
  }
}

// ============================================================================
// RESOURCE 2: Application Insights
// ============================================================================
// Application Insights monitors application performance, logs, and metrics.
// It tracks HTTP requests, exceptions, performance metrics, and custom events.
//
// - workspaceResourceId: Connects to Log Analytics workspace (for logs)
// - publicNetworkAccessForIngestion: Allow data ingestion from the web
// - publicNetworkAccessForQuery: Allow querying logs from outside
// ============================================================================

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    RetentionInDays: 30  // Keep logs for 30 days (default)
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
  tags: {
    environment: environment
    application: appName
  }
}

// ============================================================================
// RESOURCE 3: App Service (Web App)
// ============================================================================
// The App Service is the actual web application that runs on the App Service Plan.
// It hosts the ASP.NET Core application.
//
// - serverFarmId: Links to the App Service Plan (where to run)
// - httpsOnly: Enforce HTTPS for security
// - appSettings: Configuration passed to the application
// - siteConfig: Runtime configuration (.NET version, logging, etc.)
// ============================================================================

resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: webAppName
  location: location
  kind: 'app,linux'  // This is a web app running on Linux
  identity: {
    type: 'SystemAssigned'  // Enable managed identity for Azure authentication
  }
  properties: {
    serverFarmId: appServicePlan.id  // Run on the App Service Plan
    httpsOnly: true  // Force HTTPS only
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|9.0'  // .NET 9 runtime
      alwaysOn: true  // Keep the app running (prevents cold starts)
      minTlsVersion: '1.2'  // Require TLS 1.2+
      http20Enabled: true  // Enable HTTP/2
      numberOfWorkers: 1
      defaultDocuments: [
        'index.html'
      ]
      // Request logging (for debugging)
      httpLoggingEnabled: true
      // Failed request logging
      detailedErrorLoggingEnabled: true
    }
  }
  tags: {
    environment: environment
    application: appName
  }
}

// ============================================================================
// RESOURCE 4: App Service Application Settings
// ============================================================================
// These settings are environment variables passed to the .NET application.
// They're accessible in Program.cs via configuration providers.
//
// - APPINSIGHTS_INSTRUMENTATIONKEY: Connects the app to Application Insights
// - APPLICATIONINSIGHTS_CONNECTION_STRING: Modern way to connect to insights
// ============================================================================

resource appSettings 'Microsoft.Web/sites/config@2023-01-01' = {
  parent: webApp
  name: 'appsettings'
  kind: 'config'
  properties: {
    // Application Insights integration
    APPINSIGHTS_INSTRUMENTATIONKEY: appInsights.properties.InstrumentationKey
    APPLICATIONINSIGHTS_CONNECTION_STRING: 'InstrumentationKey=${appInsights.properties.InstrumentationKey}'
    // .NET environment
    ASPNETCORE_ENVIRONMENT: environment == 'prod' ? 'Production' : 'Staging'
  }
}

// ============================================================================
// RESOURCE 5: Staging Slot
// ============================================================================
// A deployment slot is an independent instance of the web app used for
// staging before swapping to production (blue-green deployments).
//
// Benefits:
// - Test changes before production users see them
// - Zero-downtime deployments (swap slots instantly)
// - Automatic warmup before swap (prevents cold starts)
// - Easy rollback (swap back if issues)
//
// This slot gets the same app settings and inherits the parent app config.
// ============================================================================

resource stagingSlot 'Microsoft.Web/sites/slots@2023-01-01' = {
  parent: webApp
  name: 'staging'
  location: location
  kind: 'app,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|9.0'
      alwaysOn: true
      minTlsVersion: '1.2'
      http20Enabled: true
      numberOfWorkers: 1
      httpLoggingEnabled: true
      detailedErrorLoggingEnabled: true
    }
  }
  tags: {
    environment: '${environment}-staging'
    application: appName
  }
}

// ============================================================================
// RESOURCE 6: Staging Slot Application Settings
// ============================================================================
// Same as production, but for the staging slot.
// This ensures staging has the same configuration as production.
// ============================================================================

resource stagingSlotSettings 'Microsoft.Web/sites/slots/config@2023-01-01' = {
  parent: stagingSlot
  name: 'appsettings'
  kind: 'config'
  properties: {
    APPINSIGHTS_INSTRUMENTATIONKEY: appInsights.properties.InstrumentationKey
    APPLICATIONINSIGHTS_CONNECTION_STRING: 'InstrumentationKey=${appInsights.properties.InstrumentationKey}'
    ASPNETCORE_ENVIRONMENT: 'Staging'
  }
}

// ============================================================================
// OUTPUTS - Values returned after deployment
// ============================================================================
// These values can be used by GitHub Actions or other scripts to configure
// deployments, DNS, or monitoring.

output webAppName string = webApp.name
output webAppUrl string = 'https://${webApp.properties.defaultHostName}'
output stagingSlotUrl string = 'https://${stagingSlot.properties.defaultHostName}'
output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
output appServicePlanId string = appServicePlan.id
output webAppId string = webApp.id
