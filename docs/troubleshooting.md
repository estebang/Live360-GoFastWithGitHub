# CI/CD Pipeline Troubleshooting Guide

This guide helps you diagnose and resolve common issues with the TailspinToys CI/CD pipeline.

## 🚨 Common Issues and Solutions

### 1. Azure Authentication Issues

#### Issue: `Error: The current subscription doesn't contain a resource group named 'xxx'`

**Cause:** Incorrect subscription or resource group name.

**Solution:**
```bash
# Verify current subscription
az account show

# List all subscriptions
az account list --output table

# Set correct subscription
az account set --subscription "your-subscription-id"

# Verify resource group exists
az group list --query "[?name=='tailspintoys-rg']"
```

#### Issue: `Error: Authentication failed`

**Cause:** OIDC federated credentials not configured correctly.

**Solution:**
```bash
# Check federated credentials
az ad app federated-credential list --id YOUR_CLIENT_ID

# Recreate federated credential if needed
az ad app federated-credential create --id YOUR_CLIENT_ID --parameters '{
  "name": "github-main",
  "issuer": "https://token.actions.githubusercontent.com", 
  "subject": "repo:OWNER/REPO:ref:refs/heads/main",
  "audiences": ["api://AzureADTokenExchange"]
}'
```

#### Issue: `Error: Insufficient privileges to complete the operation`

**Cause:** Service principal lacks required permissions.

**Solution:**
```bash
# Assign Contributor role to service principal
az role assignment create \
  --assignee YOUR_CLIENT_ID \
  --role "Contributor" \
  --scope "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/tailspintoys-rg"

# Verify role assignment
az role assignment list --assignee YOUR_CLIENT_ID
```

### 2. Build and Test Issues

#### Issue: `Error: No executable found matching command "dotnet"`

**Cause:** .NET SDK not installed or wrong version.

**Solution:**
```yaml
# In workflow file, ensure correct .NET setup
- name: Setup .NET SDK
  uses: actions/setup-dotnet@v4
  with:
    dotnet-version: '9.0.x'
```

#### Issue: `Error: The project file could not be loaded`

**Cause:** Invalid project file or path.

**Solution:**
```bash
# Validate project files locally
dotnet build TailspinToys.sln --configuration Release

# Check file paths in workflow
find . -name "*.csproj" -o -name "*.sln"
```

#### Issue: Tests fail with missing dependencies

**Cause:** Test project references not restored properly.

**Solution:**
```yaml
# Ensure proper restore before testing
- name: Restore dependencies
  run: dotnet restore TailspinToys.sln --verbosity minimal

- name: Build
  run: dotnet build --no-restore --configuration Release

- name: Test  
  run: dotnet test --no-build --configuration Release
```

### 3. Deployment Issues

#### Issue: `Error: Could not find host with name xxx.azurewebsites.net`

**Cause:** App Service name incorrect or doesn't exist.

**Solution:**
```bash
# List App Services in resource group
az webapp list --resource-group tailspintoys-rg --query "[].name"

# Verify App Service exists
az webapp show --name YOUR_APP_NAME --resource-group tailspintoys-rg
```

#### Issue: Deployment succeeds but app shows error page

**Cause:** Application configuration or startup issues.

**Solution:**
```bash
# Check application logs
az webapp log tail --name YOUR_APP_NAME --resource-group tailspintoys-rg

# Download detailed logs
az webapp log download --name YOUR_APP_NAME --resource-group tailspintoys-rg

# Check app settings
az webapp config appsettings list --name YOUR_APP_NAME --resource-group tailspintoys-rg
```

#### Issue: Health check fails after deployment

**Cause:** Health endpoint not implemented or returning errors.

**Solution:**
1. Add health endpoint to your application:
```csharp
// Program.cs
app.MapGet("/health", () => Results.Ok(new { 
    Status = "Healthy", 
    Timestamp = DateTime.UtcNow 
}));
```

2. Test health endpoint locally:
```bash
curl https://YOUR_APP_NAME.azurewebsites.net/health
```

### 4. Workflow Issues

#### Issue: Workflow doesn't trigger on push

**Cause:** Branch name doesn't match trigger configuration.

**Solution:**
```yaml
# Check trigger configuration
on:
  push:
    branches: [ main, develop, demo/* ]  # Ensure your branch matches
```

#### Issue: `Error: Resource not accessible by integration token`

**Cause:** Insufficient permissions for GitHub token.

**Solution:**
```yaml
# Add required permissions to job
jobs:
  deploy:
    permissions:
      id-token: write
      contents: read
      actions: read
```

#### Issue: Reusable workflow not found

**Cause:** Incorrect path or workflow doesn't exist.

**Solution:**
```yaml
# Verify workflow path and ensure it exists
uses: ./.github/workflows/reusable-build-and-test.yml
```

### 5. Environment and Secrets Issues

#### Issue: `Error: Secret AZURE_CLIENT_ID not found`

**Cause:** Secret not configured in repository settings.

**Solution:**
1. Go to `Settings > Secrets and Variables > Actions`
2. Add missing secrets:
   - `AZURE_CLIENT_ID`
   - `AZURE_TENANT_ID` 
   - `AZURE_SUBSCRIPTION_ID`

#### Issue: Environment protection rules blocking deployment

**Cause:** Required reviewers not approved deployment.

**Solution:**
1. Check environment protection rules in `Settings > Environments`
2. Ensure required reviewers approve deployment
3. Verify deployment branch rules

### 6. Performance Issues

#### Issue: Workflow runs very slowly

**Cause:** Various performance bottlenecks.

**Solutions:**
```yaml
# Use caching for dependencies
- name: Cache NuGet packages
  uses: actions/cache@v4
  with:
    path: ~/.nuget/packages
    key: ${{ runner.os }}-nuget-${{ hashFiles('**/*.csproj') }}

# Use parallel jobs where possible
jobs:
  build:
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest]
```

#### Issue: High resource usage in Azure

**Cause:** Insufficient App Service Plan resources.

**Solution:**
```bash
# Scale up App Service Plan
az appservice plan update \
  --name tailspintoys-plan \
  --resource-group tailspintoys-rg \
  --sku S1

# Or scale out (add more instances)
az appservice plan update \
  --name tailspintoys-plan \
  --resource-group tailspintoys-rg \
  --number-of-workers 2
```

## 🔧 Diagnostic Commands

### GitHub Actions Debugging
```bash
# Enable debug logging in workflow
- name: Enable debug logging
  run: echo "ACTIONS_STEP_DEBUG=true" >> $GITHUB_ENV
```

### Azure Diagnostics
```bash
# Check App Service status
az webapp show --name YOUR_APP_NAME --resource-group tailspintoys-rg --query "state"

# Get deployment history
az webapp deployment list --name YOUR_APP_NAME --resource-group tailspintoys-rg

# Check App Service logs
az webapp log tail --name YOUR_APP_NAME --resource-group tailspintoys-rg
```

### Local Testing
```bash
# Test build locally
dotnet clean
dotnet restore
dotnet build --configuration Release
dotnet test --configuration Release

# Test publish locally
dotnet publish src/TailspinToys.Web/TailspinToys.Web.csproj \
  --configuration Release \
  --output ./publish
```

## 📊 Monitoring and Alerting

### Set up Application Insights
```bash
# Create Application Insights
az monitor app-insights component create \
  --app tailspintoys-insights \
  --location eastus \
  --resource-group tailspintoys-rg

# Get instrumentation key
az monitor app-insights component show \
  --app tailspintoys-insights \
  --resource-group tailspintoys-rg \
  --query "instrumentationKey"
```

### Configure Alerts
```bash
# Create availability test alert
az monitor metrics alert create \
  --name "TailspinToys Health Check" \
  --resource-group tailspintoys-rg \
  --scopes /subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/tailspintoys-rg/providers/Microsoft.Web/sites/tailspintoys-prod \
  --condition "avg Http2xx < 1" \
  --window-size 5m \
  --evaluation-frequency 1m
```

## 🆘 Getting Help

### 1. Check Documentation
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Azure CLI Documentation](https://docs.microsoft.com/en-us/cli/azure/)
- [ASP.NET Core Deployment](https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/)

### 2. Review Logs
- GitHub Actions workflow logs
- Azure App Service application logs
- Azure Activity Log for resource operations

### 3. Common Log Locations
```bash
# GitHub Actions logs
# Navigate to: Repository > Actions > [Workflow Run] > [Job] > [Step]

# Azure App Service logs  
az webapp log download --name YOUR_APP_NAME --resource-group tailspintoys-rg

# Azure Activity Log
az monitor activity-log list --resource-group tailspintoys-rg
```

### 4. Support Channels
- GitHub Discussions for repository-specific issues
- Azure Support for infrastructure issues  
- Stack Overflow for technical questions
- Microsoft Q&A for Azure-specific questions

## 🔍 Advanced Troubleshooting

### Enable Verbose Logging
```yaml
# In workflow files
- name: Enable verbose logging
  run: |
    echo "ACTIONS_STEP_DEBUG=true" >> $GITHUB_ENV
    echo "ACTIONS_RUNNER_DEBUG=true" >> $GITHUB_ENV
```

### Debug Azure CLI Commands
```bash
# Add --debug flag to az commands
az webapp deploy --debug \
  --name YOUR_APP_NAME \
  --resource-group tailspintoys-rg \
  --src-path ./publish
```

### Test OIDC Token Locally
```bash
# Get OIDC token (GitHub Actions context only)
curl -H "Authorization: bearer $ACTIONS_ID_TOKEN_REQUEST_TOKEN" \
  "$ACTIONS_ID_TOKEN_REQUEST_URL&audience=api://AzureADTokenExchange"
```

## 📝 Creating Support Tickets

When creating support tickets, include:

1. **Workflow run URL** - Direct link to failed run
2. **Error messages** - Complete error text from logs  
3. **Environment details** - Azure subscription, resource group, app names
4. **Recent changes** - Any modifications made before issue occurred
5. **Reproduction steps** - How to reproduce the issue
6. **Expected vs actual behavior** - What should happen vs what happens

### Template for Support Requests
```
**Issue Summary:** Brief description of the problem

**Environment:**
- Repository: [owner/repo]
- Workflow: [workflow name]  
- Run ID: [github run id]
- Azure Subscription: [subscription id]
- Resource Group: [resource group name]

**Error Details:**
[Complete error message]

**Steps to Reproduce:**
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Expected Behavior:**
[What should happen]

**Actual Behavior:**  
[What actually happens]

**Additional Context:**
[Any other relevant information]
```

---

*Keep this guide updated as new issues and solutions are discovered.*