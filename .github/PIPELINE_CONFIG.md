# TailspinToys CI/CD Pipeline Configuration

This document outlines the configuration required for the TailspinToys CI/CD pipeline.

## 🔧 Required GitHub Repository Settings

### Repository Secrets
Configure the following secrets in your GitHub repository settings (`Settings` → `Secrets and variables` → `Actions`):

| Secret Name | Description | Example Value |
|-------------|-------------|---------------|
| `AZURE_CLIENT_ID` | Azure App Registration Client ID for OIDC | `12345678-1234-1234-1234-123456789012` |
| `AZURE_TENANT_ID` | Azure Active Directory Tenant ID | `87654321-4321-4321-4321-210987654321` |
| `AZURE_SUBSCRIPTION_ID` | Azure Subscription ID | `11111111-2222-3333-4444-555555555555` |

### Repository Variables
Configure the following variables in your GitHub repository settings (`Settings` → `Secrets and variables` → `Actions`):

| Variable Name | Description | Example Value |
|---------------|-------------|---------------|
| `AZURE_WEBAPP_NAME_DEV` | Development Azure Web App name | `tailspintoys-dev` |
| `AZURE_WEBAPP_NAME_PROD` | Production Azure Web App name | `tailspintoys-prod` |

### GitHub Environments
Create the following environments in your repository (`Settings` → `Environments`):

#### Development Environment
- **Name:** `development`
- **Protection Rules:** None (for fast iteration)
- **Reviewers:** Optional

#### Production Environment
- **Name:** `production`
- **Protection Rules:** 
  - Require reviewers (recommended: 2 reviewers)
  - Wait timer: 5 minutes (optional)
  - Restrict to main branch only

## 🔐 Azure OIDC Configuration

### 1. Create Azure App Registration
```bash
# Create the App Registration
az ad app create --display-name "TailspinToys-GitHub-OIDC"

# Note the Application (client) ID from the output
```

### 2. Create Service Principal
```bash
# Create service principal for the app registration
az ad sp create --id <APPLICATION_ID>

# Note the Object ID from the output
```

### 3. Configure Federated Credentials
For each environment, create a federated credential:

#### Development Environment
```bash
az ad app federated-credential create \
  --id <APPLICATION_ID> \
  --parameters '{
    "name": "TailspinToys-GitHub-Dev",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:<GITHUB_USERNAME>/<REPOSITORY_NAME>:ref:refs/heads/develop",
    "description": "GitHub Actions - Development",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

#### Production Environment
```bash
az ad app federated-credential create \
  --id <APPLICATION_ID> \
  --parameters '{
    "name": "TailspinToys-GitHub-Prod",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:<GITHUB_USERNAME>/<REPOSITORY_NAME>:ref:refs/heads/main",
    "description": "GitHub Actions - Production",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

### 4. Assign Azure Permissions
Grant the service principal appropriate permissions:

```bash
# For Web App deployments
az role assignment create \
  --assignee <SERVICE_PRINCIPAL_OBJECT_ID> \
  --role "Website Contributor" \
  --scope "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RESOURCE_GROUP_NAME>"

# For resource group access (if needed)
az role assignment create \
  --assignee <SERVICE_PRINCIPAL_OBJECT_ID> \
  --role "Contributor" \
  --scope "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RESOURCE_GROUP_NAME>"
```

## 🚀 Pipeline Features

### Automated Workflows
- **Pull Requests:** Build, test, and security scanning only
- **Develop Branch:** Build, test, and deploy to development environment
- **Main Branch:** Build, test, and deploy to production environment
- **Manual Dispatch:** Deploy to selected environment with optional build skip

### Security Features
- 🔐 OIDC authentication (no stored secrets)
- 🛡️ CodeQL security scanning on pull requests
- 🔒 Environment-based deployment protection
- 📊 Comprehensive deployment health checks

### Quality Assurance
- 🧪 Automated unit testing with coverage reporting
- 🔍 Code quality analysis
- 📋 Detailed deployment summaries
- ⚡ Performance optimizations with caching

### Monitoring & Observability
- 🏥 Health check endpoints
- 📈 Deployment status tracking
- 📊 Build and test metrics
- 🔄 Rollback capabilities

## 📂 File Structure
```
.github/
├── workflows/
│   ├── ci.yml                 # Main CI/CD pipeline
│   ├── dotnet-build.yml       # Reusable build workflow
│   └── azure-deploy.yml       # Reusable deployment workflow
└── PIPELINE_CONFIG.md         # This configuration guide
```

## 🔄 Workflow Execution Examples

### Feature Development
```bash
git checkout -b feature/new-campaign-page
# Make changes...
git push origin feature/new-campaign-page
# Create PR → Triggers build, test, and security scan only
```

### Development Deployment
```bash
git checkout develop
git merge feature/new-campaign-page
git push origin develop
# Triggers: Build → Test → Deploy to Development
```

### Production Release
```bash
git checkout main
git merge develop
git push origin main
# Triggers: Build → Test → Deploy to Production (with approval)
```

### Manual Deployment
1. Go to repository → Actions tab
2. Select "TailspinToys CI/CD" workflow
3. Click "Run workflow"
4. Select environment and options
5. Click "Run workflow"

## 🛠️ Troubleshooting

### Common Issues

#### OIDC Authentication Failures
- Verify federated credentials are correctly configured
- Check that the subject matches the exact branch/repo pattern
- Ensure service principal has correct Azure permissions

#### Deployment Health Check Failures
- Verify `/health` endpoint is accessible
- Check Azure Web App logs for startup issues
- Ensure application is properly configured for the environment

#### Build Failures
- Check .NET version compatibility
- Verify all NuGet packages are accessible
- Review test failures in the Actions logs

### Getting Help
- Review GitHub Actions logs for detailed error messages
- Check Azure Activity Logs for deployment issues
- Verify all required secrets and variables are configured
- Ensure environments are properly set up with protection rules