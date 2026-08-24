# Handoff

## Where are we?

The project is ready to begin Azure backend bootstrap and infrastructure provisioning. Audit, local source cleanup, and a post-audit Terraform correctness pass are complete. No project Azure resource has been created, modified, or verified yet.

## What works locally?

- Terraform 1.15.8, AzureRM 4.81.0, Helm 3.21.2, kubectl 1.34.1, Docker 29.4.0, Azure CLI 2.89.1, Git, and GitHub CLI are installed.
- `terraform init -backend=false`, `terraform fmt -check -recursive`, `terraform validate`, Helm lint/template, the local Docker build (prior unchanged source), and workflow structure review pass.
- Terraform uses an empty AzureRM backend with safe examples; no personal backend coordinate or storage key is committed.
- AKS uses Container Insights managed-identity authentication, a kubelet `AcrPull` assignment, and a control-plane subnet `Network Contributor` assignment for its Azure CNI network.
- Helm values are the sole image source, Argo has no image override, and CI builds/pushes a SHA image then commits only `image.tag`.
- Alert rules now use current `KubePodInventory` CrashLoop fields and a time-window restart delta.

## What remains unverified?

- Azure backend, provider registration, Terraform plan/apply, role effectiveness, ACR, AKS, OIDC, GitHub workflow run, image push, Argo, self-heal, Container Insights, KQL, alerts/email, Prometheus, and Grafana.
- README, historical phase guides, architecture image, and screenshot assets are inherited/stale; do not treat them as evidence.

## Important external facts

- The active Azure subscription was inspected, not changed. It is effectively empty for this project; `devops-rg` exists but is empty and must not be repurposed automatically.
- Required Azure resource providers are currently `NotRegistered`; register them before backend/apply and wait until they report `Registered`.
- The GitHub fork is public, `main` is unprotected, and GitHub CLI is authenticated as its administrator. Corrected source is pushed through `4b71395`; no Actions secrets or variables are configured.
- The default kubeconfig points to an unrelated GKE production-named context. Never run this project's kubectl/Helm commands against it. Use a dedicated, ignored project kubeconfig file once AKS exists.

## What was last done?

The audit identified and corrected three pre-deployment defects: absent AKS custom-subnet permission, CrashLoop query mismatch, and cumulative restart alert behavior. It also corrected the operating sequence so Argo is installed before, but its Application is applied only after the first real CI-produced image tag exists.

## What command/action comes next?

1. Obtain the user's Action Group recipient email.
2. Register required Azure providers and create an owner-controlled state backend.
3. Create ignored `backend.hcl` and `terraform.tfvars`, initialize remote state, plan, document cost/diff, and apply.

## What human input is needed?

- Provide the Action Group email recipient. This value stays in ignored `terraform.tfvars` and must not be copied into documentation.
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
