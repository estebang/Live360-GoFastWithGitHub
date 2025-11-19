# GitHub Actions Workflows

This directory contains optimized GitHub Actions workflows for the TailspinToys .NET application, following enterprise DevOps best practices.

## 📋 Workflow Overview

### Core Workflows

#### 1. **CI/CD** (`ci.yml`)
Main continuous integration and deployment pipeline.

**Triggers:**
- Push to `main`, `develop`, or `demo/*` branches
- Pull requests to `main`, `develop`, or `demo/*` branches
- Manual workflow dispatch

**Features:**
- Concurrent execution control (cancels in-progress runs for non-main/develop branches)
- Security scanning with CodeQL and dependency review
- Automated build and test with code coverage
- Environment-specific deployments (development/production)
- OIDC authentication for Azure
- Automated smoke tests after deployment
- Failure notifications

**Jobs:**
- `security`: Runs security scans (CodeQL, dependency review, vulnerability scanning)
- `build`: Builds and tests the application, uploads artifacts
- `deploy-dev`: Deploys to development environment (develop branch)
- `deploy-prod`: Deploys to production environment (main branch)
- `notify-failure`: Creates failure summary on workflow failure

### Reusable Workflows

#### 2. **Build .NET Application** (`build-dotnet.yml`)
Reusable workflow for building and testing .NET applications.

**Features:**
- Configurable .NET version and build configuration
- Enhanced caching with `setup-dotnet` action
- Optional test execution with coverage collection
- Test result upload and reporting
- Artifact generation for deployments
- Continuous integration build optimizations

**Inputs:**
- `dotnet-version`: .NET SDK version (default: 9.0.x)
- `configuration`: Build configuration (default: Release)
- `run-tests`: Enable/disable tests (default: true)
- `upload-artifacts`: Enable artifact upload (default: false)

**Outputs:**
- `artifact-name`: Name of the uploaded artifact

#### 3. **Deploy to Azure** (`deploy-azure.yml`)
Reusable workflow for Azure Web App deployments.

**Features:**
- Environment-specific deployments
- OIDC authentication (no stored secrets)
- Automated health checks/smoke tests
- Deployment slot support
- Comprehensive deployment summaries
- Automatic Azure logout

**Inputs:**
- `environment`: Deployment environment (development/staging/production)
- `app-name`: Azure Web App name
- `artifact-name`: Artifact to deploy
- `slot-name`: Optional deployment slot
- `run-smoke-tests`: Enable smoke tests (default: true)

**Required Secrets:**
- `azure-client-id`
- `azure-tenant-id`
- `azure-subscription-id`

#### 4. **Security Scan** (`security-scan.yml`)
Comprehensive security scanning workflow.

**Features:**
- **Dependency Review**: Reviews dependencies in PRs for security issues
- **CodeQL Scanning**: Static analysis for security vulnerabilities
- **Vulnerability Scanning**: Checks for vulnerable NuGet packages
- **SBOM Generation**: Creates Software Bill of Materials

**Jobs:**
- `dependency-review`: Runs on pull requests only
- `code-scanning`: CodeQL analysis for C# code
- `vulnerability-scan`: Scans for vulnerable dependencies
- `sbom-generation`: Generates SPDX 2.2 SBOM

### Quality & Testing Workflows

#### 5. **PR Quality Checks** (`pr-quality.yml`)
Automated quality checks for pull requests.

**Features:**
- PR size analysis and warnings for large PRs
- Code formatting verification
- Automated PR comment with check results
- Concurrent execution control per PR

**Jobs:**
- `pr-metadata`: Analyzes PR size and complexity
- `code-quality`: Verifies code formatting
- `build-pr`: Builds and tests the PR
- `comment-summary`: Posts summary comment on PR

#### 6. **Matrix Build** (`matrix-build.yml`)
Cross-platform and cross-version testing.

**Features:**
- Dynamic matrix strategy
- Tests on multiple operating systems (Linux, Windows, macOS)
- Tests on multiple .NET versions (8.0.x, 9.0.x)
- Optional preview version testing
- Platform-specific build commands

**Platforms:**
- Ubuntu Latest
- Windows Latest
- macOS Latest (optional)

**Trigger Options:**
- Automatic on PRs affecting code
- Manual dispatch with preview version option

#### 7. **Performance Monitoring** (`performance.yml`)
Performance analysis and benchmarking.

**Features:**
- Build size analysis
- Test execution time tracking
- Application startup performance
- Memory usage analysis
- Resource consumption metrics

**Jobs:**
- `benchmark`: Analyzes build size and test performance
- `startup-performance`: Measures application startup time
- `resource-usage`: Tracks memory and resource usage

### Maintenance Workflows

#### 8. **Scheduled Maintenance** (`scheduled-maintenance.yml`)
Weekly automated maintenance tasks.

**Schedule:** Every Monday at 9:00 AM UTC

**Features:**
- Dependency update checks
- Security vulnerability scanning
- Automatic issue creation for vulnerabilities
- Workflow run cleanup (retains 30 days)
- Workflow health reporting

**Jobs:**
- `dependency-update-check`: Reports outdated packages
- `security-audit`: Weekly vulnerability scan
- `cache-cleanup`: Removes old workflow runs
- `workflow-health`: Generates workflow statistics

### Automation Workflows

#### 9. **Auto Label PRs** (`auto-label.yml`)
Automatically labels pull requests based on changed files.

**Features:**
- File-based categorization (workflows, source, tests, docs, dependencies, config)
- PR size labeling (XS/S/M/L/XL)
- Automatic label application
- Label summary generation

#### 10. **Validate Workflows** (`validate-workflows.yml`)
Validates workflow file syntax and structure.

**Features:**
- YAML syntax validation
- Workflow structure checks
- Validation result summary
- Runs on workflow file changes

## 📋 Additional Configuration

### Dependabot (`dependabot.yml`)
Automated dependency updates for:
- GitHub Actions (weekly)
- NuGet packages for main project (weekly)
- NuGet packages for test project (weekly)
- Grouped updates for related packages (EF Core, xUnit, etc.)

### Code Owners (`CODEOWNERS`)
Automatic reviewer assignment:
- Workflow changes: DevOps team
- Source code: Development team
- Documentation: All teams

## 🔐 Security Features

### 1. **Least Privilege Permissions**
All workflows use minimal required permissions:
```yaml
permissions:
  contents: read
  id-token: write  # Only for OIDC
  security-events: write  # Only for security scans
```

### 2. **OIDC Authentication**
Azure deployments use OpenID Connect (no stored credentials):
- Short-lived tokens
- Automatic rotation
- Reduced secret management

### 3. **Dependency Scanning**
Multiple layers of security:
- Pull request dependency reviews
- Weekly vulnerability scans
- Automatic issue creation
- SBOM generation

### 4. **CodeQL Analysis**
Static code analysis:
- Security and quality queries
- C# language scanning
- SARIF upload to Security tab

## ⚡ Performance Optimizations

### 1. **Caching Strategy**
```yaml
- uses: actions/setup-dotnet@v4
  with:
    cache: true
    cache-dependency-path: '**/*.csproj'
```
- Automatic NuGet package caching
- Project file-based cache keys
- Fallback cache restoration

### 2. **Concurrency Control**
```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```
- Cancels redundant runs
- Saves compute time
- Protects main/develop branches

### 3. **Artifact Reuse**
- Build once, deploy many times
- Artifacts uploaded after build
- Same artifact deployed to all environments
- Reduced build time for deployments

### 4. **Parallel Job Execution**
- Independent jobs run in parallel
- Security scans don't block builds
- Multiple environment deployments

### 5. **Optimized Build Commands**
```bash
dotnet build --no-restore
dotnet test --no-build
dotnet publish --no-build
```
- Incremental builds
- Skips redundant operations
- Reduces total workflow time

## 📊 Monitoring & Observability

### 1. **Job Summaries**
All workflows generate GitHub Step Summaries with:
- Deployment information
- Test results
- Security scan results
- Performance metrics

### 2. **Test Reporting**
- Test results uploaded as artifacts
- Visual test reporter integration
- Code coverage tracking with Codecov

### 3. **Deployment Tracking**
- Environment URLs in deployment status
- Smoke test results
- Deployment history per environment

### 4. **Failure Notifications**
- Automatic failure summaries
- Context-rich error information
- Links to workflow runs

## 🔧 Configuration

### Required Secrets

Set these in GitHub Repository Settings > Secrets and variables > Actions:

#### Azure Deployment (using OIDC)
- `AZURE_CLIENT_ID`: Azure AD application client ID
- `AZURE_TENANT_ID`: Azure AD tenant ID
- `AZURE_SUBSCRIPTION_ID`: Azure subscription ID

#### Optional
- `CODECOV_TOKEN`: Codecov upload token (for private repos)

### Required Variables

Set these in GitHub Repository Settings > Secrets and variables > Actions > Variables:

- `AZURE_WEBAPP_NAME_DEV`: Development environment app name
- `AZURE_WEBAPP_NAME_PROD`: Production environment app name

### Environment Configuration

Create these environments in GitHub Repository Settings > Environments:

#### `development`
- Protection rules: None (auto-deploy on develop)
- Secrets: Use repository-level secrets

#### `production`
- Protection rules: Required reviewers
- Secrets: Use repository-level secrets
- Deployment branches: `main` only

## 🚀 Usage Examples

### Manual Deployment
```bash
# Trigger workflow manually
gh workflow run ci.yml \
  --ref develop \
  -f skip-tests=false \
  -f force-deploy=true
```

### Running Matrix Tests
```bash
# Test across all platforms with preview versions
gh workflow run matrix-build.yml \
  --ref feature/my-branch \
  -f include-preview=true
```

### Scheduled Maintenance
```bash
# Run maintenance tasks manually
gh workflow run scheduled-maintenance.yml
```

## 📝 Best Practices Implemented

✅ **Security**
- OIDC authentication
- Least privilege permissions
- Dependency scanning
- CodeQL analysis
- SBOM generation

✅ **Performance**
- Intelligent caching
- Concurrency control
- Artifact reuse
- Parallel execution

✅ **Reliability**
- Health checks
- Smoke tests
- Error handling
- Retry logic

✅ **Maintainability**
- Reusable workflows
- Clear job names
- Comprehensive documentation
- Automated cleanup

✅ **Observability**
- Job summaries
- Test reporting
- Deployment tracking
- Workflow health monitoring

## 🔄 Workflow Dependencies

```
ci.yml (Main Workflow)
├── security-scan.yml
│   ├── Dependency Review
│   ├── CodeQL Scanning
│   ├── Vulnerability Scan
│   └── SBOM Generation
├── build-dotnet.yml
│   ├── Build
│   ├── Test
│   └── Publish Artifacts
└── deploy-azure.yml (called twice)
    ├── Deploy to Development
    └── Deploy to Production

pr-quality.yml (PR Workflow)
├── PR Metadata Check
├── Code Quality Check
├── build-dotnet.yml
└── Comment Summary

matrix-build.yml (Testing Workflow)
└── Cross-platform builds

performance.yml (Performance Workflow)
├── Build Size Analysis
├── Startup Performance
└── Resource Usage

scheduled-maintenance.yml (Weekly Maintenance)
├── Dependency Updates
├── Security Audit
├── Cache Cleanup
└── Workflow Health

auto-label.yml (PR Automation)
└── Auto-apply labels

validate-workflows.yml (Quality Gate)
└── Validate workflow syntax

Dependabot (Automated Updates)
├── GitHub Actions dependencies
├── NuGet packages (main project)
└── NuGet packages (test project)
```

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [.NET DevOps with GitHub Actions](https://docs.microsoft.com/en-us/dotnet/devops/)
- [Azure OIDC Configuration](https://docs.microsoft.com/en-us/azure/developer/github/connect-from-azure)
- [CodeQL for C#](https://codeql.github.com/docs/codeql-language-guides/codeql-for-csharp/)

## 🐛 Troubleshooting

### Build Failures
1. Check .NET version compatibility
2. Review cache status
3. Verify dependency restoration
4. Check test logs

### Deployment Failures
1. Verify Azure credentials (OIDC)
2. Check environment variables
3. Review smoke test results
4. Verify app service status

### Security Scan Failures
1. Review vulnerable dependencies
2. Check CodeQL alerts
3. Update to secure package versions
4. Review security advisories

---

*Last Updated: 2025-11-19*
*Maintained by: GitHub Actions Specialist*
