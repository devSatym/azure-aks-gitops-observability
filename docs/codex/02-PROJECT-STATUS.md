# Project Status

## Current Phase

Phase 5 — Terraform plan and infrastructure provisioning preparation.

## Current Status

Repository audit, source cleanup, Terraform correctness corrections, Azure provider registration, and owner-controlled remote-state bootstrap are complete. The corrected source is pushed to `origin/main`. No AKS, ACR, Log Analytics workspace, alert rule, or application resource exists yet. Terraform plan/apply is paused only for a user-selected Action Group email recipient.

## Completed

- Audited all implementation files, inherited documentation/evidence, Git state/remotes, Azure inventory/provider state, GitHub configuration names, and requested stale-value markers.
- Preserved the untracked user brief `plan.md`; no `AGENTS.md` exists in this repository.
- Completed local migration: empty AzureRM backend, ignored `backend.hcl`, safe input examples, tracked provider lock, managed-identity Container Insights configuration, `azure-webapp` identity, no raw manifests, Helm-only image source, corrected Argo source/no image overrides, and CI-to-GitOps workflow.
- Added subnet-scoped `Network Contributor` for the AKS control-plane system identity and enabled managed-identity role-assignment replication tolerance.
- Corrected Azure Monitor KQL rules: node readiness uses `Status !contains "Ready"`; CrashLoop detection uses `ContainerStatusReason`; restart alert evaluates a 15-minute restart delta rather than a cumulative all-time count.
- Confirmed safe sequencing: install Argo first, but apply the Application only after CI has committed the first real ACR SHA tag.
- Documented a dedicated-project kubeconfig requirement so commands never target the existing unrelated GKE context.
- Secret-scanned and pushed the reviewed source/documentation migration to `origin/main` through `0768bfa`.
- Registered required Azure providers: Storage, Network, Compute, Managed Identity, Container Service, Container Registry, Operational Insights, Operations Management, and Insights.
- Created `rg-aksops-dev-tfstate` in Central India, `staksopsdevtf20260824` (StorageV2/Standard_LRS, TLS 1.2, public blob access disabled, shared-key access disabled), and its private `tfstate` container.
- Assigned the Terraform operator `Storage Blob Data Contributor` at the state storage account scope and initialized the AzureRM backend using Entra/Azure CLI authentication.

## In Progress

- Prepare ignored Terraform deployment inputs and review a Terraform plan immediately after the alert recipient is supplied.

## Blocked

- Terraform plan/apply requires `alert_email`. The value is intentionally absent from tracked source and has not been assumed from the signed-in account.
- Live AKS/ACR/OIDC/Argo/monitoring/alert/Grafana validation necessarily waits for infrastructure and external configuration.

## Next Action

Provide the email address that should receive Azure Monitor Action Group notifications. Unless directed otherwise, the deployment plan will use the documented example inputs: Central India, `project_name = "aksops"`, `environment = "dev"`, `node_count = 2`, and `node_vm_size = "Standard_D2s_v5"`, subject to quota/availability checks. The actual selected values will remain in ignored `terraform.tfvars`.

## Azure Resources Created

- State resource group: `rg-aksops-dev-tfstate` (Central India).
- State storage account: `staksopsdevtf20260824` (StorageV2 / Standard_LRS; TLS 1.2; public blob and shared-key access disabled).
- State container: `tfstate`, private.
- RBAC: Terraform operator has `Storage Blob Data Contributor` at the state storage-account scope.
- No project application resource group, VNet, AKS, ACR, Log Analytics workspace, Action Group, or alert rule has been created.
- The pre-existing empty `devops-rg` remains untouched.

## GitHub Configuration

- Repository: `devSatym/azure-aks-gitops-observability` (public, default branch `main`, no branch protection).
- GitHub CLI is authenticated as repository administrator; corrected source is pushed through `0768bfa`.
- No repository Actions secrets or variables exist yet.
- Required later secrets: `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`.
- Required later variables: `ACR_NAME`, `ACR_LOGIN_SERVER`, `IMAGE_NAME=azure-webapp`.
- No client secret is required or intended.

## Validation Completed

| Check | Result |
| --- | --- |
| `terraform init -backend=false` | PASS with AzureRM 4.81.0 and Random 3.9.0 |
| `terraform fmt -check -recursive` | PASS after current Terraform corrections |
| `terraform validate` | PASS after current Terraform corrections and remote-backend initialization |
| Helm lint/template | PASS; one Service and one two-replica Deployment render; Helm reports only an optional icon recommendation |
| Local workflow structure | PASS; OIDC/ACR/GitOps update present, no direct AKS/Helm/Argo deployment command |
| Azure account / inventory | PASS, read-only; one enabled/default subscription inspected without switch |
| Azure provider registration | PASS; all required providers now report `Registered` |
| Remote AzureRM backend | PASS; Entra/Azure CLI init, private container access, and empty state blob confirmed |
| GitHub repository / configuration inventory | PASS, read-only; administrator access, no secrets/variables |
| Live Terraform/AKS/ACR/OIDC/Argo/monitoring/Grafana | NOT RUN; application infrastructure/configuration does not exist yet |

## Known Issues

- `helm/azure-webapp/values.yaml` deliberately uses a non-deployable bootstrap ACR repository/tag. Replace the repository after Terraform outputs it, and do not apply the Argo Application until a real SHA tag is present in Git.
- The current default kubeconfig points to a GKE production-named context and is unreachable. It must not be used for this project; use a dedicated, ignored project kubeconfig after AKS exists.
- README, phase guides, architecture PNG, and screenshots are inherited/stale and must not be treated as evidence. They are deferred until validation is observed.
- Role-assignment propagation may delay AKS networking/ACR access after apply; wait/verify rather than adding broad permissions.

## Important Commands

```bash
# Local checks
terraform fmt -check -recursive
terraform validate
helm lint ./helm/azure-webapp
helm template azure-webapp ./helm/azure-webapp

# Remote backend
terraform init -reconfigure -backend-config=backend.hcl

# After an approved plan/apply, with explicit project kubeconfig only
az aks get-credentials --resource-group <rg> --name <aks> --file <project-kubeconfig>
kubectl --kubeconfig <project-kubeconfig> get nodes
```

## Local Commits

- Source migration/current corrections are pushed through `0768bfa`; the untracked user brief `plan.md` remains excluded.

## Last Updated

2026-08-24, Asia/Kolkata — completed Azure backend bootstrap; awaiting alert-recipient input before a real plan/apply.
