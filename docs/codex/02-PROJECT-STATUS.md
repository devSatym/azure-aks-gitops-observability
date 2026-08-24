# Project Status

## Current Phase

Phases 5–7 complete; Phase 12 (Argo CD installation) and Phase 13 (first CI-to-GitOps delivery) in progress.

## Current Status

Repository audit, source cleanup, Terraform correctness corrections, Azure provider registration, remote state, and the reviewed Terraform apply are complete. AKS, ACR, Log Analytics, Action Group, and all three alert rules exist. Both AKS nodes are Ready through the isolated kubeconfig. CI has passwordless ACR-scoped configuration but has not yet run; Argo CD is not yet installed and the application remains intentionally undeployed until CI creates its first SHA image.

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
- Applied the reviewed plan successfully: 13 added, 0 changed, and 0 destroyed.
- Verified the new AKS cluster and its two nodes are Ready using only `/tmp/azure-aks-gitops-observability.kubeconfig`; system and Container Insights pods are Running.
- Verified the Basic ACR is provisioned with admin access disabled and legacy registry permissions, so its scoped `AcrPush` role is applicable.
- Updated Helm's sole image repository to the real ACR and re-ran Helm lint/template; `image.tag` remains the intentional `bootstrap` placeholder.
- Created a dedicated Entra CI application/service principal, configured a main-branch GitHub OIDC federation from GitHub's live immutable subject prefix, granted `AcrPush` at the ACR only, and configured the required GitHub secret/variable names. No client secret or ACR admin credential was created.

## In Progress

- Install Argo CD with Helm into `argocd`, then trigger and inspect the first CI image promotion before applying the Application.

## Blocked

- No current prerequisite is blocked. Later telemetry, alert-delivery, Grafana, and screenshot tests wait on their natural ingestion or human-confirmation gates.

## Next Action

Install Argo CD, wait for its core pods, then push one harmless `app/` change. CI must first produce and commit a real immutable SHA tag; only then apply the Argo Application. Major ongoing cost drivers are the two `Standard_D2s_v5` AKS worker nodes, the AKS Standard Load Balancer/public IP, Log Analytics ingestion and 30-day retention, and the Basic ACR. No destructive action is planned.

## Azure Resources Created

- State resource group: `rg-aksops-dev-tfstate` (Central India).
- State storage account: `staksopsdevtf20260824` (StorageV2 / Standard_LRS; TLS 1.2; public blob and shared-key access disabled).
- State container: `tfstate`, private.
- RBAC: Terraform operator has `Storage Blob Data Contributor` at the state storage-account scope.
- Project resource group: `rg-aksops-dev-n8bo7j` (Central India).
- AKS: `aks-aksops-dev-n8bo7j`, Kubernetes 1.35, Azure CNI, two Ready nodes.
- ACR: `acraksopsdevn8bo7j` (Basic; admin disabled; legacy registry permissions).
- Log Analytics: `law-aksops-dev-n8bo7j` (30-day retention), Action Group, and three AKS scheduled-query rules.
- Project VNet/subnet plus ACR Pull and subnet Network Contributor role assignments.
- The pre-existing empty `devops-rg` remains untouched.

## GitHub Configuration

- Repository: `devSatym/azure-aks-gitops-observability` (public, default branch `main`, no branch protection).
- GitHub CLI is authenticated as repository administrator; corrected source is pushed through `82b814e`.
- Configured Actions secrets: `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID` (values are not recorded).
- Configured Actions variables: `ACR_NAME`, `ACR_LOGIN_SERVER`, `IMAGE_NAME=azure-webapp`.
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
| Terraform apply | PASS; 13 added, 0 changed, 0 destroyed |
| ACR baseline | PASS; Basic SKU, provisioned, admin disabled |
| AKS baseline / isolated kubeconfig | PASS; two Ready nodes and system/Container Insights pods running through dedicated project kubeconfig |
| GitHub OIDC configuration | PASS (configuration); dedicated federation and ACR-scoped `AcrPush` configured, real login pending |
| GitHub repository / configuration inventory | PASS; administrator access and required secret/variable names confirmed without reading secret values |
| Argo / first CI promotion / workload / Grafana | NOT RUN; staged in the documented safe order |

## Known Issues

- `helm/azure-webapp/values.yaml` deliberately retains the non-deployable `bootstrap` tag, although its repository now points at the real ACR. Do not apply the Argo Application until a real SHA tag is present in Git.
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

- Source migration/current corrections are pushed through `82b814e`; the untracked user brief `plan.md` remains excluded.

## Last Updated

2026-08-24, Asia/Kolkata — Terraform applied (13 added); AKS/ACR/OIDC baseline verified; installing Argo and proving the first CI promotion next.
