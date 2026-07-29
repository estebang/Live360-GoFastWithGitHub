# GitHub Actions CI/CD Deployment Guide (OIDC)

This guide explains how to set up and configure the CI/CD workflow for deploying TailspinToys to Azure App Service using **OIDC authentication** (recommended for production).

## Workflow Overview

The `.github/workflows/ci-cd.yml` workflow provides:

1. **Build & Test** (runs on all push/PR events)
   - Restores NuGet dependencies
   - Builds in Release configuration
   - Runs xUnit tests
   - Publishes the application

2. **Deploy to Staging** (runs on push to `develop` branch)
   - Authenticates to Azure via OIDC
   - Deploys to staging App Service
   - Requires `staging` environment approval (optional)

3. **Deploy to Production** (runs on push to `main` branch)
   - Authenticates to Azure via OIDC
   - Deploys to production App Service
   - Requires `production` environment approval (recommended)

---

## Prerequisites

### Azure Setup

1. **Create two App Service instances** (or one with deployment slots):
   - `tailspintoys-staging` (for develop branch)
   - `tailspintoys` (for main branch)

2. **Create a Service Principal** with Contributor role:
   ```powershell
   # Log in to Azure
   az login

   # Create service principal (replace with your subscription ID and app name)
   az ad sp create-for-rbac --name "github-actions-tailspin" --role contributor --scopes /subscriptions/{subscription-id}
   ```

   This command outputs:
   ```json
   {
     "appId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
     "displayName": "github-actions-tailspin",
     "password": "xxxx~xxxxxxxxxxxxxxxxxxxxxxxxxxxx",
     "tenant": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
   }
   ```

   **Save these values—you'll need them for GitHub secrets.**

### GitHub Setup

1. **Enable Environments** (recommended):
   - Go to repo → Settings → Environments
   - Create `staging` and `production` environments
   - Add required reviewers for production

2. **Configure Repository Secrets**:
   - Go to repo → Settings → Secrets and variables → Actions
   - Add the following secrets:

```
AZURE_CLIENT_ID       # Service Principal appId
AZURE_TENANT_ID       # Service Principal tenant ID
AZURE_SUBSCRIPTION_ID # Your Azure Subscription ID
```

**To add secrets:**
- Click "New repository secret"
- Copy values from service principal output
- Name them exactly as shown above

3. **Configure OIDC Trust** (GitHub → Azure):
   ```powershell
   # Create federated credential to allow GitHub Actions to authenticate
   # Replace placeholders with your values
   
   $resourceGroupName = "your-resource-group"
   $appName = "github-actions-tailspin"
   
   az identity federated-credential create \
     --name "github-actions-tailspin" \
     --identity-name $appName \
     --resource-group $resourceGroupName \
     --issuer "https://token.actions.githubusercontent.com" \
     --subject "repo:YOUR_GITHUB_ORG/YOUR_REPO:ref:refs/heads/main" \
     --audiences "api://AzureADTokenExchange"
   ```

   **Or use Azure Portal:**
   - App Registrations → your-service-principal → Certificates & secrets
   - Click "Federated credentials"
   - Add GitHub:
     - Organization: `YOUR_GITHUB_ORG`
     - Repository: `YOUR_REPO`
     - Entity type: `Branch`
     - Branch name: `main`

---

## Configuration

### 1. Update Azure Resource Names

Edit `.github/workflows/ci-cd.yml` and update:

```yaml
env:
  AZURE_WEBAPP_NAME: 'tailspintoys'  # Your production App Service name
  AZURE_RESOURCE_GROUP: 'your-resource-group'  # Your Azure resource group
```

### 2. Set Branch Deployment Rules

The workflow uses:
- **`develop`** branch → deploys to staging
- **`main`** branch → deploys to production

Modify the branch names in the `on` section or job conditionals if needed.

### 3. Optional: Add Manual Approval Gates

To require approval before production deployment:

1. Go to Settings → Environments → production
2. Click "Add deployment branch rule"
3. Select "Required reviewers"
4. Add team members who can approve

---

## OIDC Authentication Flow

When the workflow runs:

1. GitHub Actions generates a JWT token scoped to your repo
2. The workflow calls `azure/login@v2` with the OIDC credentials
3. Azure verifies the token matches the federated credential
4. Access is granted without exposing secrets
5. Deployment proceeds with authenticated Azure access

**Security benefits:**
- No publish profiles stored as secrets
- No long-lived credentials
- Automatic token rotation
- Audit trail in Azure AD

---

## Workflow Execution

### On Pull Request
- Builds and tests the code
- Does **NOT** deploy
- Shows test results in PR checks

### On Push to `develop`
- Builds and tests
- **Deploys to staging** (if tests pass)

### On Push to `main`
- Builds and tests
- **Deploys to production** (if tests pass)
- Requires approval (if environment rule is configured)

---

## Monitoring Deployments

1. **GitHub**: repo → Actions → Select workflow run
   - View build logs
   - Check OIDC login success in logs
   - Download artifact if needed

2. **Azure Portal**: App Service → Deployment Center
   - View deployment history
   - Check Application Settings
   - Rollback if needed

3. **Application Insights** (optional):
   - Monitor application performance post-deployment

---

## Troubleshooting

### OIDC Login Fails: "Federated credential not found"

**Solution:**
- Verify federated credential exists in Azure Portal
- Confirm subject matches your branch: `repo:ORG/REPO:ref:refs/heads/main`
- Check that issuer is exactly: `https://token.actions.githubusercontent.com`
- Audiences must be: `api://AzureADTokenExchange`

### Deployment Fails: "Insufficient privileges"

**Solution:**
- Service principal needs Contributor role on App Service
- Check Azure Portal → Resource → Access control (IAM)
- Ensure service principal is assigned Contributor role
- May take a few minutes to propagate

### Build Fails: "dotnet SDK not found"

**Solution:**
- Confirm `.NET 9.x` is available
- Check Ubuntu runner includes .NET 9
- Update `DOTNET_VERSION` if needed

### Tests Fail

**Solution:**
- Run tests locally: `dotnet test`
- Check test output in GitHub Actions logs
- Fix failing tests before merging to main/develop

### App Service Health Check Fails After Deploy

**Solution:**
- Check Application Insights diagnostics
- Verify environment variables in App Service settings
- Confirm .NET 9 runtime is available on App Service
- Add startup probe delay in Azure Portal if needed

---

## Secret Rotation

OIDC tokens are **automatically rotated** by GitHub Actions. No action needed.

If you need to rotate the service principal:

1. **Create new service principal**:
   ```powershell
   az ad sp create-for-rbac --name "github-actions-tailspin-v2" --role contributor
   ```

2. **Update GitHub secrets** with new values

3. **Update federated credentials** if using different branch names

4. **Delete old service principal** (optional):
   ```powershell
   az ad sp delete --id {old-appId}
   ```

---

## Next Steps

1. **Create service principal** and save credentials
2. **Configure federated credential** in Azure
3. **Add GitHub secrets** for OIDC
4. **Update workflow** with correct resource names
5. **Push to `develop`** to test staging deployment
6. **Create PR to `main`** and merge to test production

For questions, refer to:
- [GitHub OIDC Documentation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [Azure CLI Service Principal](https://learn.microsoft.com/en-us/cli/azure/ad/sp)
- [Azure App Service Deployment](https://learn.microsoft.com/en-us/azure/app-service/deploy-github-actions)
