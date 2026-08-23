# Handoff

## Where are we?

Repository audit, planning, local implementation cleanup, and local validation completed on 2026-08-23. No cloud resource has been created, modified, or verified by this session.

## What works?

- Repository source is available and structurally complete enough for local cleanup.
- Terraform 1.15.8, Helm 3.21.2, kubectl client 1.34.1, Docker 29.4.0, and Git 2.43.0 are installed.
- The local source has an empty AzureRM backend with safe examples, a tracked provider lock, AKS-to-ACR `AcrPull`, managed-identity Container Insights authentication, one Helm + Argo CD deployment model, and three Azure Monitor scheduled-query alert definitions.
- Terraform format/validate, Helm lint/template, workflow YAML parsing, the isolated image-tag update logic, and a local Docker build passed.

## What does not work or remain unverified?

- Azure CLI and GitHub CLI are absent. Therefore no account/subscription, resource, workflow, OIDC, ACR, AKS, Argo, log, alert, email, Prometheus, or Grafana result has been validated.
- The bootstrap image repository in Helm values must be replaced with the actual Terraform-created ACR login server before Argo CD is applied.
- README and historical phase documents remain intentionally unchanged until their claims can be evidence-backed.

## What was last done?

Removed stale backend/Argo/CI/raw-manifest coupling; added configuration examples and provider lock; enabled managed-identity monitoring; and created the required tracking documents. The completed work is in commits `26aa55e`, `72f0869`, `da509a2`, and `672fb67`. The only remaining uncommitted file is the pre-existing `plan.md`, which remains untouched.

## What command should be run next?

Install Azure CLI, then run:

```bash
az login
az account show
```

## What human input is needed?

- Authenticate Azure and confirm the active subscription; do not silently switch subscriptions. After login, tell Codex `continue`.
- Provide/confirm the Action Group alert email.
- Authorize Entra federation/RBAC creation and GitHub repository secrets/variables if the current identity cannot create them.
- Later, capture fresh screenshots and confirm the Action Group notification. Do not reuse inherited screenshots as evidence.

## What Azure resources currently exist?

Unknown. This session has not run Azure CLI or Terraform against any subscription.

## Is it safe to stop/restart?

Yes. Read `02-PROJECT-STATUS.md` and `01-IMPLEMENTATION-PLAN.md` first. No destructive action or cloud-side mutation has occurred. Do not run `terraform destroy`; it always needs explicit user approval.
