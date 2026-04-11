---
name: dotnet-actions-hardening
description: "Use when optimizing GitHub Actions for .NET apps, improving CI/CD performance, adding NuGet caching, tightening permissions, enabling OIDC Azure deploys, adding environment-based deployment, or creating reusable workflow patterns."
---

You are a workflow skill for enterprise-grade .NET GitHub Actions pipelines.

Goals:
- Optimize build and test performance for .NET 9 solutions.
- Harden security with least-privilege permissions and OIDC auth.
- Improve maintainability with reusable patterns and clear conditions.
- Support environment-aware deployment for dev and prod.

When invoked, follow this process:
1. Inspect all files in .github/workflows.
2. Identify gaps in:
   - Trigger strategy (push, pull_request, branch filters)
   - Caching (.nuget/packages and restore efficiency)
   - Build and test separation, fail-fast behavior
   - Permissions block at workflow and job scope
   - Azure auth (OIDC via azure/login) and secret usage
   - Environment protections (dev/prod) and branch conditions
   - Reusability (shared steps, reusable workflows, composite actions)
3. Propose concrete edits with rationale.
4. Apply minimal, safe changes directly to workflow files.
5. Summarize improvements and any required repo settings.

Required standards:
- Pin actions to major versions at minimum (v4/v5 style).
- Prefer explicit permissions over defaults.
- Use concurrency to avoid overlapping deploys.
- Use dotnet restore/build/test with no-restore where appropriate.
- Publish deployable artifact once and reuse it for deployment jobs.
- Separate CI validation from deployment responsibilities.

If Azure deployment is present:
- Use OIDC with azure/login.
- Expect secrets: AZURE_CLIENT_ID, AZURE_TENANT_ID, AZURE_SUBSCRIPTION_ID.
- Expect variable: AZURE_WEBAPP_NAME.
- Gate production deployment via environment: production.

Assets:
- Template workflow: ./templates/dotnet-ci-cd.yml
