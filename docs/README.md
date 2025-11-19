# TailspinToys CI/CD Documentation

This directory contains comprehensive documentation for the TailspinToys CI/CD pipeline and deployment processes.

## 📚 Documentation Index

### 🚀 Getting Started
- **[Quick Setup Guide](quick-setup.md)** - 15-minute setup guide for getting the CI/CD pipeline running
- **[CI/CD Pipeline Documentation](ci-cd-pipeline.md)** - Complete documentation of the pipeline architecture and features

### 🔧 Operations
- **[Troubleshooting Guide](troubleshooting.md)** - Common issues and solutions for pipeline problems

## 📋 Quick Reference

### Essential Links
- [Main CI/CD Pipeline](./.github/workflows/ci.yml)
- [PR Preview Deployments](./.github/workflows/pr-preview.yml) 
- [Hotfix Deployments](./.github/workflows/hotfix-deploy.yml)
- [Reusable Build Workflow](./.github/workflows/reusable-build-and-test.yml)
- [Reusable Deploy Workflow](./.github/workflows/reusable-azure-deploy.yml)

### Key Features
- ✅ **Automated CI/CD** with GitHub Actions
- ✅ **Multi-environment** deployment (dev, staging, production)
- ✅ **PR preview** environments for testing
- ✅ **Hotfix deployment** capability
- ✅ **Azure OIDC** authentication (no long-lived secrets)
- ✅ **Reusable workflows** for consistency
- ✅ **Security scanning** and code quality checks
- ✅ **Health checks** and monitoring
- ✅ **Team notifications** (Teams/Slack)

### Required Secrets
| Secret | Purpose |
|--------|---------|
| `AZURE_CLIENT_ID` | Azure service principal client ID |
| `AZURE_TENANT_ID` | Azure tenant ID |  
| `AZURE_SUBSCRIPTION_ID` | Azure subscription ID |

### Required Variables
| Variable | Purpose |
|----------|---------|
| `AZURE_WEBAPP_NAME_DEV` | Development app service name |
| `AZURE_WEBAPP_NAME_STAGING` | Staging app service name |
| `AZURE_WEBAPP_NAME_PROD` | Production app service name |

### Deployment Flow
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   develop   │───▶│ Development │    │    main     │───▶│   Staging   │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                                                                 │
                                                                 ▼
                                                        ┌─────────────┐
                                                        │ Production  │
                                                        │ (approval)  │
                                                        └─────────────┘
```

## 🆘 Need Help?

1. **Quick Issues**: Check the [Troubleshooting Guide](troubleshooting.md)
2. **Setup Problems**: Follow the [Quick Setup Guide](quick-setup.md)
3. **Complex Issues**: Review the [Full Documentation](ci-cd-pipeline.md)
4. **Still Stuck**: Create an issue in the repository

## 🔄 Keeping Documentation Updated

This documentation should be updated when:
- New workflow features are added
- Azure resource configurations change
- New secrets or variables are required
- Deployment processes are modified
- Common issues and solutions are discovered

---

*Documentation maintained by the DevOps team. Last updated: November 2024*