# Deploy TailspinToys Infrastructure to Azure

param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroup,
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "eastus",
    
    [Parameter(Mandatory=$false)]
    [string]$AppName = "tailspintoys",
    
    [Parameter(Mandatory=$false)]
    [string]$Environment = "prod",
    
    [Parameter(Mandatory=$false)]
    [string]$Sku = "B2"
)

Write-Host "🚀 Deploying TailspinToys Infrastructure" -ForegroundColor Cyan
Write-Host ""

# Check if logged in
$account = az account show 2>$null
if (-not $account) {
    Write-Host "❌ Not logged into Azure. Running 'az login'..." -ForegroundColor Red
    az login
}

# Get current subscription
$subscription = az account show --query "id" -o tsv
Write-Host "📍 Subscription: $subscription" -ForegroundColor Green

# Create resource group if it doesn't exist
Write-Host ""
Write-Host "📦 Creating/checking resource group: $ResourceGroup" -ForegroundColor Cyan
az group create `
    --name $ResourceGroup `
    --location $Location `
    --output none

Write-Host "✅ Resource group ready" -ForegroundColor Green

# Validate template
Write-Host ""
Write-Host "🔍 Validating Bicep template..." -ForegroundColor Cyan
az deployment group validate `
    --resource-group $ResourceGroup `
    --template-file "main.bicep" `
    --parameters `
        location=$Location `
        appName=$AppName `
        environment=$Environment `
        appServiceSku=$Sku

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Validation failed" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Template validation passed" -ForegroundColor Green

# Deploy
Write-Host ""
Write-Host "⚙️  Deploying resources..." -ForegroundColor Cyan
Write-Host "  - App Service Plan ($Sku)"
Write-Host "  - App Service"
Write-Host "  - Staging Slot"
Write-Host "  - Application Insights"
Write-Host ""

$deployment = az deployment group create `
    --resource-group $ResourceGroup `
    --template-file "main.bicep" `
    --parameters `
        location=$Location `
        appName=$AppName `
        environment=$Environment `
        appServiceSku=$Sku `
    --output json | ConvertFrom-Json

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Deployment failed" -ForegroundColor Red
    exit 1
}

# Extract outputs
$outputs = $deployment.properties.outputs
$webAppName = $outputs.webAppName.value
$webAppUrl = $outputs.webAppUrl.value
$stagingUrl = $outputs.stagingSlotUrl.value
$appInsightsKey = $outputs.appInsightsInstrumentationKey.value

# Display results
Write-Host ""
Write-Host "✅ Deployment completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Resources Created:" -ForegroundColor Cyan
Write-Host "  Resource Group: $ResourceGroup"
Write-Host "  Region: $Location"
Write-Host ""
Write-Host "🌐 URLs:" -ForegroundColor Cyan
Write-Host "  Production: $webAppUrl"
Write-Host "  Staging:    $stagingUrl"
Write-Host ""
Write-Host "📊 Monitoring:" -ForegroundColor Cyan
Write-Host "  App Insights Key: $appInsightsKey"
Write-Host ""
Write-Host "🔧 Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Add AZURE_CLIENT_ID, AZURE_TENANT_ID, AZURE_SUBSCRIPTION_ID to GitHub secrets"
Write-Host "  2. Configure federated credential for GitHub OIDC"
Write-Host "  3. Push code to 'develop' or 'main' branch to trigger deployment"
Write-Host ""
Write-Host "📚 Resources:" -ForegroundColor Cyan
Write-Host "  Resource Group URL: https://portal.azure.com/#@microsoft.com/resource/subscriptions/$subscription/resourceGroups/$ResourceGroup/overview"
Write-Host ""
