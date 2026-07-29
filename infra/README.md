# Azure Infrastructure Deployment Guide

This directory contains Bicep templates for deploying TailspinToys to Azure.

## Files

- **`main.bicep`** — Main infrastructure template (App Service Plan, App Service, Slots, App Insights)
- **`main.bicepparam`** — Parameters file (customize for your environment)
- **`deploy.ps1`** — PowerShell deployment script

## Resources Deployed

### 1. **App Service Plan**
- Defines the compute resources (CPU, memory, instances)
- Linux-based for cost efficiency
- Shared by web app and staging slot
- **Why:** Groups compute so you pay once for both production and staging

### 2. **App Service (Web App)**
- Hosts the ASP.NET Core 9.0 application
- HTTPS-only for security
- Always-on to prevent cold starts
- System-assigned managed identity for Azure authentication
- **Why:** This is your actual web application

### 3. **Application Insights**
- Monitors application performance, logs, exceptions
- Tracks HTTP requests and custom metrics
- 30-day retention by default
- Integrated with the web app via connection string
- **Why:** See what's happening in production; debug issues

### 4. **Staging Slot**
- Independent instance of the web app for testing
- Same configuration as production
- Enables zero-downtime deployments (blue-green)
- Automatic warmup before swap (prevents cold starts)
- **Why:** Test changes before users see them; instant rollback capability

## Deployment Steps

### 1. Login to Azure

```powershell
az login
az account set --subscription "beb42746-5273-42f6-afa7-ef72398d9b04"
```

### 2. Create Resource Group

```powershell
az group create `
  --name tailspintoys-rg `
  --location eastus
```

### 3. Edit Parameters (Optional)

Open `main.bicepparam` and customize:
- `location` — Azure region (eastus, westus2, etc.)
- `appName` — Application name
- `environment` — Environment name (prod, staging, dev)
- `appServiceSku` — Size (B1=cheap, B2=medium, S1=standard, P1V2=premium)

### 4. Deploy

```powershell
az deployment group create `
  --resource-group tailspintoys-rg `
  --template-file infra/main.bicep `
  --parameters infra/main.bicepparam
```

Or use the provided script:

```powershell
.\infra\deploy.ps1 -ResourceGroup "tailspintoys-rg" -Location "eastus"
```

### 5. View Outputs

After deployment, you'll see:
- Web App URL (production)
- Staging URL
- Application Insights key
- Resource IDs

## Cost Estimation

| Resource | B1 | B2 | S1 |
|----------|-----|-----|-----|
| App Service Plan | $11/mo | $22/mo | $40/mo |
| Application Insights | $2/mo | $2/mo | $2/mo |
| Storage (logs) | ~$1/mo | ~$1/mo | ~$1/mo |
| **Total** | **~$14/mo** | **~$25/mo** | **~$43/mo** |

## Customization

### Change SKU
In `main.bicepparam`, update:
```bicep
param appServiceSku = 'S1'  // B1, B2, S1, S2, P1V2, etc.
```

### Add Custom Domain
The template creates a subdomain on `azurewebsites.net`. To use a custom domain:
1. Deploy template first
2. In Azure Portal → App Service → Custom domains
3. Add your domain and update DNS records

### Change .NET Version
In `main.bicep`, find `linuxFxVersion` and update:
```bicep
linuxFxVersion: 'DOTNETCORE|8.0'  // or 7.0, 6.0, etc.
```

### Scale to Multiple Instances
In `main.bicep`, update `capacity` in App Service Plan:
```bicep
capacity: 3  // Run 3 instances instead of 1
```

## Monitoring

After deployment:

1. **Azure Portal** → Resource Group → tailspintoys-rg
   - See all resources and their status

2. **Application Insights** → Metrics
   - View requests, failures, response times

3. **App Service** → Logs
   - View application output and errors

4. **GitHub Actions** → Deployments
   - See deployment history and logs

## Cleanup

To remove all resources:

```powershell
az group delete --name tailspintoys-rg --yes
```

## References

- [Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [App Service Plans](https://learn.microsoft.com/en-us/azure/app-service/overview-hosting-plans)
- [Deployment Slots](https://learn.microsoft.com/en-us/azure/app-service/deploy-staging-slots)
- [Application Insights](https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview)
