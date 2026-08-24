# Handoff

## Where are we?

The project is ready to apply a reviewed Terraform plan and provision application infrastructure. Audit, local source cleanup, a post-audit Terraform correctness pass, provider registration, remote-state bootstrap, and the real plan are complete. Only the dedicated state backend has been created; no AKS/ACR/application resource exists yet.

## What works locally?

- Terraform 1.15.8, AzureRM 4.81.0, Helm 3.21.2, kubectl 1.34.1, Docker 29.4.0, Azure CLI 2.89.1, Git, and GitHub CLI are installed.
- `terraform init -backend=false`, `terraform fmt -check -recursive`, `terraform validate`, Helm lint/template, the local Docker build (prior unchanged source), and workflow structure review pass.
- `terraform init -reconfigure -backend-config=backend.hcl` succeeds against the private state container using the Azure CLI/Entra session; no storage key is used.
- Terraform uses an empty AzureRM backend with safe examples; no personal backend coordinate or storage key is committed.
- AKS uses Container Insights managed-identity authentication, a kubelet `AcrPull` assignment, and a control-plane subnet `Network Contributor` assignment for its Azure CNI network.
- Helm values are the sole image source, Argo has no image override, and CI builds/pushes a SHA image then commits only `image.tag`.
- Alert rules now use current `KubePodInventory` CrashLoop fields and a time-window restart delta.

## What remains unverified?

- Terraform plan/apply, role effectiveness, ACR, AKS, OIDC, GitHub workflow run, image push, Argo, self-heal, Container Insights, KQL, alerts/email, Prometheus, and Grafana.
- README, historical phase guides, architecture image, and screenshot assets are inherited/stale; do not treat them as evidence.

## Important external facts

- The active Azure subscription was inspected without a subscription switch. It now has the dedicated state backend: `rg-aksops-dev-tfstate`, `staksopsdevtf20260824`, and private `tfstate`; `devops-rg` remains empty and untouched.
- Required Azure resource providers now report `Registered`.
- The GitHub fork is public, `main` is unprotected, and GitHub CLI is authenticated as its administrator. Corrected source is pushed through `bd6ac01`; no Actions secrets or variables are configured.
- The default kubeconfig points to an unrelated GKE production-named context. Never run this project's kubectl/Helm commands against it. Use a dedicated, ignored project kubeconfig file once AKS exists.

## What was last done?

The audit identified and corrected three pre-deployment defects: absent AKS custom-subnet permission, CrashLoop query mismatch, and cumulative restart alert behavior. It also corrected the operating sequence so Argo is installed before, but its Application is applied only after the first real CI-produced image tag exists. A dedicated AzureRM backend was then created, secured with Entra RBAC, and initialized successfully. Ignored deployment inputs were then created, and the saved remote-state plan was reviewed: 13 intended creates, with no changes or destroys.

## What command/action comes next?

1. Apply the reviewed saved plan.
2. Collect outputs, update the Helm image repository, then configure Azure/GitHub OIDC and ACR-scoped CI access.

## What human input is needed?

- Confirm the notification when the controlled alert test occurs.
- If Azure tenant policy prevents Entra application/federated credential creation, provide the required authorization rather than switching to a client secret.
- Capture fresh screenshots later; inherited screenshots cannot be used as proof.

## Safe credential and cluster commands

```bash
# Do not inspect or change the existing default kubeconfig for this project.
PROJECT_KUBECONFIG=/tmp/azure-aks-gitops-observability.kubeconfig

az aks get-credentials \
  --resource-group <resource-group> \
  --name <aks-cluster> \
  --file "$PROJECT_KUBECONFIG"

kubectl --kubeconfig "$PROJECT_KUBECONFIG" get nodes
```

## Is it safe to stop/restart?

Yes. Read `00-REPO-AUDIT.md`, `01-IMPLEMENTATION-PLAN.md`, and `02-PROJECT-STATUS.md` first. Do not run `terraform destroy`; destruction requires explicit user approval only after evidence and documentation are complete.
