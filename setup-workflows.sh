#!/bin/bash
# Setup script for GitHub Actions workflows
# This script moves workflow files from repository root to .github/workflows

set -e

echo "Setting up GitHub Actions workflows for TailspinToys..."

# Create workflows directory if it doesn't exist
mkdir -p .github/workflows

# Move workflow files from repository root to .github/workflows
echo "Moving workflow files..."
mv workflow-ci-cd.yml .github/workflows/ci-cd.yml
mv workflow-reusable-build.yml .github/workflows/reusable-build.yml
mv workflow-security.yml .github/workflows/security.yml
mv workflow-deploy.yml .github/workflows/deploy.yml
mv workflow-pr-validation.yml .github/workflows/pr-validation.yml

echo "✅ Workflow files moved successfully!"
echo ""
echo "Files created:"
ls -la .github/workflows/

echo ""
echo "Next steps:"
echo "1. Review the workflow files"
echo "2. Configure GitHub secrets (AZURE_CLIENT_ID, AZURE_TENANT_ID, AZURE_SUBSCRIPTION_ID)"
echo "3. Create GitHub environments (dev, staging, production)"
echo "4. Commit and push the changes:"
echo "   git add .github/workflows/"
echo "   git commit -m 'Add GitHub Actions workflows'"
echo "   git push"
echo ""
echo "For detailed information, see WORKFLOWS-README.md and WORKFLOWS-SETUP.md"
