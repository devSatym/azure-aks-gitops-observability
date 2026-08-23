# Project Status

## Current Phase

Phase 4 — Azure backend bootstrap and infrastructure provisioning.

## Current Status

Repository audit, implementation planning, and all currently possible local implementation work are complete. No Azure state has been inferred or changed. Azure bootstrap is blocked until Azure CLI is available and the user authenticates.

## Completed

- Audited repository structure, Git remote/branch/status, Terraform root/modules, workflow, Helm chart, Argo Application, application, historical documentation, and requested search terms.
- Recorded verified upstream/stale configuration and README mismatches in `00-REPO-AUDIT.md`.
- Created implementation, validation, decision, and handoff tracking documents.
- Replaced the hardcoded AzureRM backend with an empty backend, added an ignored local-backend pattern, and added safe `backend.hcl.example` and `terraform.tfvars.example` files.
- Generated `.terraform.lock.hcl` with AzureRM 4.81.0 and Random 3.9.0; it is no longer ignored.
- Enabled supported managed-identity authentication for the AKS `oms_agent` monitoring configuration.
- Updated the static page and made Helm values the single image source with a documented, non-deployable bootstrap ACR placeholder.
- Removed stale Argo image overrides and corrected the Argo source URL to this repository.
- Converted CI to OIDC-based ACR build/push plus a deterministic GitOps `image.tag` commit; removed AKS variables and credential retrieval.
- Removed the unused raw `k8s/` manifests after successful Helm lint/render validation.
- Completed local Terraform formatting/validation and Helm lint/template checks.

## In Progress

- Await Azure access so the owner-controlled Terraform backend can be created and initialization can target the selected subscription.

## Blocked

- Azure backend bootstrap, Terraform plan/apply, live AKS/ACR checks, OIDC setup, Argo installation, end-to-end delivery, monitoring, alerting, and Prometheus/Grafana validation are blocked because Azure CLI is not installed and no Azure login/subscription has been verified.
- GitHub repository settings/secrets/variables and workflow execution cannot be verified because GitHub CLI is not installed and no authenticated GitHub session is available.

## Next Action

Install Azure CLI, run `az login`, then tell Codex to continue. The next safe action is `az account show`; the active subscription will be reported without being changed. Also be ready to provide the Action Group alert-email address.

## Azure Resources Created

None created by this implementation session. Existing resources are unknown and unverified.

## GitHub Configuration

- Origin-derived repository: `devSatym/azure-aks-gitops-observability`.
- Required future secrets: `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`.
- Required future variables: `ACR_NAME`, `ACR_LOGIN_SERVER`, `IMAGE_NAME=azure-webapp`.
- No client secret is required or intended.

## Validation Completed

- Terraform CLI present: 1.15.8.
- Helm CLI present: 3.21.2.
- kubectl client present: 1.34.1.
- Docker CLI present: 29.4.0.
- Azure CLI, GitHub CLI, and `yq` are absent.
- `terraform init -backend=false`: passed; AzureRM 4.81.0 and Random 3.9.0 were locked locally.
- `terraform fmt -check -recursive`: passed.
- `terraform validate`: passed.
- Workflow YAML parsing and the isolated `image.tag` update logic: passed.
- `helm lint ./helm/azure-webapp`: passed (informational missing-icon recommendation only).
- `helm template azure-webapp ./helm/azure-webapp`: passed; renders exactly one Service and one Deployment with two replicas.
- `docker build --tag azure-webapp:local-validation ./app`: passed; produced a local Linux/amd64 image.
- Live cloud, cluster, workflow, alert, and dashboard tests: not run.

## Known Issues

- The chart deliberately contains a bootstrap ACR placeholder. Replace it with the Terraform output's real ACR login server once infrastructure exists; CI then changes only `image.tag`.
- README and historical phase docs still overstate validation and describe direct deployment paths. They are intentionally deferred for the evidence-backed final-documentation phase.
- Terraform plan/apply requires an owner-created backend and local tfvars; neither has been created.

## Important Commands

```bash
terraform init -backend=false
terraform fmt -check -recursive
terraform validate
helm lint ./helm/azure-webapp
helm template azure-webapp ./helm/azure-webapp

# Required before Azure bootstrap:
az login
az account show
```

## Local Commits

- `26aa55e` — `infra: make terraform backend and monitoring auth configurable`
- `72f0869` — `refactor: make helm values the deployment source of truth`
- `da509a2` — `ci: implement ACR to GitOps image promotion`
- `672fb67` — `docs: add repository audit and implementation plan`

## Last Updated

2026-08-23, Asia/Kolkata — local implementation and validation committed; awaiting Azure CLI login.
