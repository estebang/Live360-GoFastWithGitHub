# Quick Setup Guide for TailspinToys CI/CD

This guide will help you quickly set up the CI/CD pipeline for TailspinToys.

## 🚀 Prerequisites

- Azure subscription with contributor access
- GitHub repository with admin access
- Azure CLI installed and configured
- .NET 9 SDK installed

## ⚡ Quick Setup (15 minutes)

### Step 1: Create Azure Resources (5 minutes)

```bash
# Set variables
RESOURCE_GROUP="tailspintoys-rg"
LOCATION="eastus"
APP_SERVICE_PLAN="tailspintoys-plan"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create App Service Plan
az appservice plan create \
  --name $APP_SERVICE_PLAN \
  --resource-group $RESOURCE_GROUP \
  --sku B1 \
  --is-linux

# Create App Services
az webapp create \
  --name "tailspintoys-dev-$(date +%s)" \
  --resource-group $RESOURCE_GROUP \
  --plan $APP_SERVICE_PLAN \
  --runtime "DOTNETCORE:9.0"

az webapp create \
  --name "tailspintoys-staging-$(date +%s)" \
  --resource-group $RESOURCE_GROUP \
  --plan $APP_SERVICE_PLAN \
  --runtime "DOTNETCORE:9.0"

az webapp create \
  --name "tailspintoys-prod-$(date +%s)" \
  --resource-group $RESOURCE_GROUP \
  --plan $APP_SERVICE_PLAN \
  --runtime "DOTNETCORE:9.0"
```

### Step 2: Setup OIDC Authentication (5 minutes)

```bash
# Get your subscription and tenant IDs
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)

# Create service principal
SP_JSON=$(az ad sp create-for-rbac \
  --name "tailspintoys-github-actions" \
  --role "Contributor" \
  --scopes "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP")

CLIENT_ID=$(echo $SP_JSON | jq -r '.appId')

# Create federated credentials for main branch
az ad app federated-credential create \
  --id $CLIENT_ID \
  --parameters '{
    "name": "tailspintoys-main",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:YOUR_USERNAME/YOUR_REPO:ref:refs/heads/main",
    "audiences": ["api://AzureADTokenExchange"]
  }'

# Create federated credentials for develop branch
az ad app federated-credential create \
  --id $CLIENT_ID \
  --parameters '{
    "name": "tailspintoys-develop", 
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:YOUR_USERNAME/YOUR_REPO:ref:refs/heads/develop",
    "audiences": ["api://AzureADTokenExchange"]
  }'

echo "Save these values for GitHub secrets:"
echo "AZURE_CLIENT_ID: $CLIENT_ID"
echo "AZURE_TENANT_ID: $TENANT_ID" 
echo "AZURE_SUBSCRIPTION_ID: $SUBSCRIPTION_ID"
```

### Step 3: Configure GitHub Repository (5 minutes)

#### Add Secrets
Go to `Settings > Secrets and Variables > Actions > Secrets`:

| Secret | Value |
|--------|-------|
| `AZURE_CLIENT_ID` | Output from Step 2 |
| `AZURE_TENANT_ID` | Output from Step 2 |
| `AZURE_SUBSCRIPTION_ID` | Output from Step 2 |

#### Add Variables  
Go to `Settings > Secrets and Variables > Actions > Variables`:

| Variable | Value |
|----------|-------|
| `AZURE_WEBAPP_NAME_DEV` | Your dev app name |
| `AZURE_WEBAPP_NAME_STAGING` | Your staging app name |  
| `AZURE_WEBAPP_NAME_PROD` | Your prod app name |

#### Create Environments
Go to `Settings > Environments` and create:
- `development` (no protection)
- `staging` (optional protection)
- `production` (require reviewers)

## 🧪 Test the Setup

### 1. Test Development Deployment
```bash
# Create develop branch and push
git checkout -b develop
git push origin develop
```

### 2. Test Production Deployment  
```bash
# Merge to main and push
git checkout main
git merge develop
git push origin main
```

### 3. Test PR Preview
1. Create a feature branch
2. Make changes and create a pull request
3. Check for preview deployment comment

## 🔧 Optional Configurations

### Code Coverage (Codecov)
1. Sign up at [codecov.io](https://codecov.io)
2. Get your repository token
3. Add `CODECOV_TOKEN` secret

### Code Quality (SonarCloud)
1. Sign up at [sonarcloud.io](https://sonarcloud.io)
2. Create project and get token
3. Add `SONAR_TOKEN` secret

### Notifications
Add webhook URLs as secrets:
- `TEAMS_WEBHOOK_URL` for Microsoft Teams
- `SLACK_WEBHOOK_URL` for Slack

## 🆘 Troubleshooting

### Common Issues

**Azure login fails**
```bash
# Verify federated credentials
az ad app federated-credential list --id $CLIENT_ID
```

**App Service not found**
```bash  
# List your app services
az webapp list --resource-group $RESOURCE_GROUP --query "[].name"
```

**Workflow fails on first run**
- Check all secrets are set correctly
- Verify app service names match variables
- Ensure environments are created

### Getting Help

1. Check workflow logs in GitHub Actions
2. Review Azure App Service logs  
3. Consult the [full documentation](ci-cd-pipeline.md)
4. Open an issue in the repository

## ✅ Verification Checklist

- [ ] Azure resources created successfully
- [ ] Service principal and OIDC configured
- [ ] GitHub secrets and variables set
- [ ] GitHub environments created  
- [ ] Development deployment works
- [ ] Production deployment requires approval
- [ ] PR preview creates deployment slots
- [ ] Health checks pass after deployment

---

**🎉 Congratulations!** Your CI/CD pipeline is now ready to use.