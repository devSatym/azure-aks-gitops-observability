# Project Status

## Current Phase

Phase 4 — Azure backend bootstrap and Phase 5 deployment-input preparation.

## Current Status

Repository audit, source cleanup, and a second Terraform correctness pass are complete locally. Azure CLI and GitHub CLI are authenticated, but no Azure resource has been created or changed. The source has not yet been pushed: local `main` is seven commits ahead of `origin/main`. Terraform plan/apply is deliberately paused for a user-selected Action Group email recipient.

## Completed

- Audited all implementation files, inherited documentation/evidence, Git state/remotes, Azure inventory/provider state, GitHub configuration names, and requested stale-value markers.
- Preserved the untracked user brief `plan.md`; no `AGENTS.md` exists in this repository.
- Completed the earlier local migration: empty AzureRM backend, ignored `backend.hcl`, safe input examples, tracked provider lock, managed-identity Container Insights configuration, `azure-webapp` identity, no raw manifests, Helm-only image source, corrected Argo source/no image overrides, and CI-to-GitOps workflow.
- Reconciled the audit/implementation plan with the current checkout instead of retaining the historical upstream-starting-state claims.
- Added subnet-scoped `Network Contributor` for the AKS control-plane system identity and enabled managed-identity role-assignment replication tolerance.
- Corrected the Azure Monitor KQL rules: node readiness uses `Status !contains "Ready"`; CrashLoop detection uses `ContainerStatusReason`; restart alert evaluates a 15-minute restart delta instead of a cumulative all-time count.
- Confirmed the safer sequencing: install Argo first, but apply the Application only after CI has committed the first real ACR SHA tag.
- Documented a dedicated-project kubeconfig requirement so commands never target the existing unrelated GKE context.

## In Progress

- Commit and secret-scan the current Terraform/documentation corrections, then push all reviewed local commits to the fork before GitHub Actions or Argo CD is configured.
- Prepare owner-controlled backend/bootstrap commands and deployment inputs without persisting credentials.

## Blocked

- Terraform plan/apply needs an Action Group recipient. The value is intentionally absent from tracked source and has not been assumed from the signed-in account.
- Live AKS/ACR/OIDC/Argo/monitoring/alert/Grafana validation necessarily waits for infrastructure and external configuration.

## Next Action

Provide the email address that should receive Azure Monitor Action Group notifications. Unless directed otherwise, the deployment plan will use the documented example inputs: Central India, `project_name = "aksops"`, `environment = "dev"`, `node_count = 2`, and `node_vm_size = "Standard_D2s_v5"`, subject to quota/availability checks. The actual selected values will remain in ignored `terraform.tfvars`.

## Azure Resources Created

- None by this implementation.
- The active subscription has one pre-existing empty `devops-rg` in Central India; it will not be repurposed automatically.
- No AKS cluster, ACR, Storage account, or Log Analytics workspace exists in the active subscription.
- `Microsoft.Storage`, `Microsoft.Network`, `Microsoft.Compute`, `Microsoft.ManagedIdentity`, `Microsoft.ContainerService`, `Microsoft.ContainerRegistry`, `Microsoft.OperationalInsights`, and `Microsoft.Insights` were `NotRegistered` when inspected. Registration is an upcoming required, non-billable subscription change.

## GitHub Configuration

- Repository: `devSatym/azure-aks-gitops-observability` (public, default branch `main`, no branch protection).
- GitHub CLI is authenticated as the repository administrator.
- No repository Actions secrets or variables exist yet.
- Required later secrets: `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`.
- Required later variables: `ACR_NAME`, `ACR_LOGIN_SERVER`, `IMAGE_NAME=azure-webapp`.
- No client secret is required or intended.

## Validation Completed

| Check | Result |
| --- | --- |
| `terraform init -backend=false` | PASS with AzureRM 4.81.0 and Random 3.9.0 |
| `terraform fmt -check -recursive` | PASS after current Terraform corrections |
| `terraform validate` | PASS after current Terraform corrections |
| Helm lint/template | PASS; one Service and one two-replica Deployment render; Helm reports only an optional icon recommendation |
| Local workflow structure | PASS; OIDC/ACR/GitOps update present, no direct AKS/Helm/Argo deployment command |
| Azure account / inventory | PASS, read-only; one enabled/default subscription inspected without switch |
| GitHub repository / configuration inventory | PASS, read-only; administrator access, no secrets/variables |
| Live Terraform/AKS/ACR/OIDC/Argo/monitoring/Grafana | NOT RUN; infrastructure/configuration does not exist yet |

## Known Issues

- `helm/azure-webapp/values.yaml` deliberately uses a non-deployable bootstrap ACR repository/tag. Replace the repository after Terraform outputs it, and do not apply the Argo Application until a real SHA tag is present in Git.
- The current default kubeconfig points to a GKE production-named context and is unreachable. It must not be used for this project; use a dedicated, ignored project kubeconfig after AKS exists.
- README, phase guides, architecture PNG, and screenshots are inherited/stale and must not be treated as evidence. They are deferred until validation is observed.
- Role-assignment propagation may delay AKS networking/ACR access after apply; wait/verify rather than adding broad permissions.

## Important Commands

```bash
# Local checks
terraform init -backend=false
terraform fmt -check -recursive
terraform validate
helm lint ./helm/azure-webapp
helm template azure-webapp ./helm/azure-webapp

# Read-only account check
az account show

# After bootstrap / with explicit project kubeconfig only
terraform init -reconfigure -backend-config=backend.hcl
az aks get-credentials --resource-group <rg> --name <aks> --file <project-kubeconfig>
kubectl --kubeconfig <project-kubeconfig> get nodes
```

## Local Commits

- Earlier local-only commits: `26aa55e`, `72f0869`, `da509a2`, `672fb67`, `7d433fe`.
- Current completion set: `1e5211e` (AKS network/alert corrections) and the documentation reconciliation recorded with this status update.

## Last Updated

2026-08-24, Asia/Kolkata — completed current audit/correctness pass; awaiting alert-recipient input before a real plan/apply.
