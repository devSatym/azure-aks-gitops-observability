# Project Status

## Current Phase

Phases 5–14 and the Prometheus/Grafana baseline are complete; Azure-native telemetry ingestion is in progress.

## Current Status

Repository audit, source cleanup, Terraform correctness corrections, Azure provider registration, remote state, Terraform apply, passwordless CI, Argo CD, the first CI-to-GitOps delivery, and a self-heal drift test are complete. The live application is `Synced`/`Healthy` with two Ready pods and a working LoadBalancer response. Prometheus/Grafana baseline checks pass. Container Insights diagnosis found that AKS runs the managed-identity add-on without the required DCR/DCRA resources; a saved Terraform correction plan adds exactly those two resources.

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
- Installed Helm chart `argo-cd` 10.4.0 / Argo CD 3.5.1 into `argocd`; all core components and the Application CRD are healthy.
- Proved the first CI → Git → Argo delivery: GitHub OIDC login, Docker build, ACR push of `azure-webapp:9d37a77`, and the bot's one-field `image.tag` update all succeeded. Argo synchronized commit `751d2c4`; its two pods serve the visible delivery marker through the LoadBalancer.
- Proved Argo self-heal: the temporary four-replica drift became OutOfSync and returned to Git's two replicas in 28 seconds with no Git edit.
- Installed `kube-prometheus-stack` 88.5.4 in `monitoring`. Prometheus has 18/18 active targets and the application replica metric; Grafana is healthy with 29 supplied dashboards.
- Inspected the Action Group and all three enabled scheduled-query rules without exposing the recipient. Each rule has a five-minute frequency and 15-minute window.
- Added `docs/screenshots/README.md` to distinguish inherited images from the 13 required fresh captures.
- Diagnosed empty Log Analytics data: `ama-logs` is healthy and AKS reports managed-identity monitoring enabled, but Azure has no `Microsoft.Insights/dataCollectionRules` or DCR association and agent logs report missing DCR JSON.

## In Progress

- Apply the saved two-resource Container Insights DCR/DCRA plan, then re-query Log Analytics for pod/node records before running the controlled failed-pod alert test.

## Blocked

- No infrastructure prerequisite is blocked. The reviewed monitoring correction is ready to apply; fresh ingestion, alert delivery, and owner screenshots remain later gates.

## Next Action

Apply the reviewed Container Insights correction: 2 creates (DCR and DCR association), 0 changes, 0 destroys. It adds no compute resource, but enables the intended full Container Insights stream set and therefore Log Analytics ingestion. After fresh pod/node records appear, create one disposable `restartPolicy: Never` failed pod, observe the KQL match and fired alert, delete the pod, and ask the recipient to confirm notification delivery. Major ongoing cost drivers are the two `Standard_D2s_v5` AKS worker nodes, the AKS Standard Load Balancer/public IP, Log Analytics ingestion and 30-day retention, Basic ACR, and the in-cluster monitoring stack. No destructive action is planned.

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
- Argo CD Helm release in `argocd` (chart 10.4.0 / app 3.5.1).
- `azure-webapp` Argo Application and its two-replica LoadBalancer Deployment in `default`.
- `kube-prometheus-stack` Helm release in `monitoring` (chart 88.5.4).
- The pre-existing empty `devops-rg` remains untouched.

## GitHub Configuration

- Repository: `devSatym/azure-aks-gitops-observability` (public, default branch `main`, no branch protection).
- GitHub CLI is authenticated as repository administrator; the first source delivery is `9d37a77` and its bot GitOps commit is `751d2c4`.
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
| GitHub OIDC configuration and real login | PASS; dedicated federation/ACR-scoped `AcrPush` configured and first workflow OIDC login succeeded |
| GitHub repository / configuration inventory | PASS; administrator access and required secret/variable names confirmed without reading secret values |
| First CI-to-GitOps promotion | PASS; source SHA image exists, bot changed only `image.tag`, and no CI AKS/Helm/Argo deployment occurred |
| Argo CD / application | PASS; chart 10.4.0 / app 3.5.1 core healthy; Application Synced/Healthy at `751d2c4` |
| Workload response | PASS; rollout has two Ready pods and the LoadBalancer response contains the delivery marker |
| Drift correction | PASS; Argo restored replicas 4 → 2 in 28 seconds without a Git change |
| Azure Monitor rules | PASS (configuration); Action Group and three enabled five-minute/15-minute KQL rules inspected |
| Prometheus / Grafana | PASS (baseline); Prometheus 18/18 active targets and workload replica metric; Grafana healthy with 29 dashboards |
| Container Insights / KQL / fired alert | IN PROGRESS; diagnosis found the missing DCR/DCRA and a saved two-create corrective plan |

## Known Issues

- The deployed Helm value is the immutable `9d37a77` tag; CI remains the only allowed writer of `image.tag`.
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

- The application source and bot GitOps commits are pushed through `751d2c4`; the untracked user brief `plan.md` remains excluded.

## Last Updated

2026-08-24, Asia/Kolkata — first CI-to-GitOps delivery, self-heal, and Prometheus/Grafana baseline pass; applying the reviewed Container Insights DCR/DCRA correction next.
