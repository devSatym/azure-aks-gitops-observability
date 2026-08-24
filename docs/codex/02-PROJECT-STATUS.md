# Project Status

## Current Phase

Phase 5 — Terraform plan reviewed; infrastructure provisioning in progress.

## Current Status

Repository audit, source cleanup, Terraform correctness corrections, Azure provider registration, owner-controlled remote-state bootstrap, and a real Terraform plan are complete. The corrected source is pushed to `origin/main`. The reviewed plan contains only the intended 13 creates and no changes or destroys. Infrastructure has not yet been applied, so no project AKS, ACR, Log Analytics workspace, alert rule, or application resource exists yet.

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
- Created ignored deployment inputs using the documented Central India / `aksops` / `dev` / two-node `Standard_D2s_v5` defaults and the user-supplied Action Group recipient. The recipient remains local and untracked.
- Ran `terraform fmt -check -recursive`, `terraform validate`, and a remote-state Terraform plan successfully.
- Reviewed the plan: 13 creates, 0 changes, and 0 destroys. Planned resources are the project resource group, VNet/subnet, ACR, AKS, Log Analytics workspace, two role assignments, Action Group, and three scheduled-query alert rules, plus the deterministic random suffix.

## In Progress

- Apply the reviewed, saved Terraform plan and collect the resulting non-sensitive outputs.

## Blocked

- Live AKS/ACR/OIDC/Argo/monitoring/alert/Grafana validation necessarily waits for the current Terraform apply and subsequent external configuration.

## Next Action

Apply the reviewed saved plan. Its major expected cost drivers are the two `Standard_D2s_v5` AKS worker nodes, the AKS Standard Load Balancer/public IP, Log Analytics ingestion and 30-day retention, and a Basic ACR. The remote-state storage cost is expected to be minimal. No destructive action is planned.

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
| Terraform plan | PASS; saved remote-state plan has 13 creates, 0 changes, and 0 destroys |
| GitHub repository / configuration inventory | PASS, read-only; administrator access, no secrets/variables |
| Live Terraform apply / AKS / ACR / OIDC / Argo / monitoring / Grafana | NOT RUN; Terraform apply is next |

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

- Source migration/current corrections are pushed through `bd6ac01`; the untracked user brief `plan.md` remains excluded.

## Last Updated

2026-08-24, Asia/Kolkata — reviewed a real remote-state plan (13 creates, no changes/destroys); applying the saved plan next.
