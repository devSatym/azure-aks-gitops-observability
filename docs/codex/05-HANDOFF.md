# Handoff

## Where are we?

The project has a provisioned Azure environment and is ready to install Argo CD, then prove its first CI-to-GitOps delivery. Terraform applied the reviewed plan as 13 adds with no changes or destruction. The application remains intentionally undeployed until CI publishes a real immutable image tag.

## What works locally?

- Terraform 1.15.8, AzureRM 4.81.0, Helm 3.21.2, kubectl 1.34.1, Docker 29.4.0, Azure CLI 2.89.1, Git, and GitHub CLI are installed.
- `terraform init -backend=false`, `terraform fmt -check -recursive`, `terraform validate`, Helm lint/template, the local Docker build (prior unchanged source), and workflow structure review pass.
- `terraform init -reconfigure -backend-config=backend.hcl` succeeds against the private state container using the Azure CLI/Entra session; no storage key is used.
- Terraform uses an empty AzureRM backend with safe examples; no personal backend coordinate or storage key is committed.
- AKS uses Container Insights managed-identity authentication, a kubelet `AcrPull` assignment, and a control-plane subnet `Network Contributor` assignment for its Azure CNI network.
- Helm values are the sole image source, Argo has no image override, and CI builds/pushes a SHA image then commits only `image.tag`.
- Alert rules now use current `KubePodInventory` CrashLoop fields and a time-window restart delta.
- The project ACR is Basic with admin access disabled; the two-node Azure CNI AKS cluster is Ready and Container Insights agents are running.
- A dedicated Entra application/service principal has a GitHub main-branch federation and ACR-scoped `AcrPush`; the expected GitHub secret and variable names are configured without a client secret.

## What remains unverified?

- A real GitHub OIDC login, image push/tag, GitOps promotion commit, Argo installation/application health, workload response, self-heal, telemetry/KQL data, alert delivery, Prometheus, Grafana, and screenshots.
- README, historical phase guides, architecture image, and screenshot assets are inherited/stale; do not treat them as evidence.

## Important external facts

- The active Azure subscription was inspected without a subscription switch. It has the dedicated state backend plus `rg-aksops-dev-n8bo7j`, `aks-aksops-dev-n8bo7j`, `acraksopsdevn8bo7j`, `law-aksops-dev-n8bo7j`, VNet/subnet, Action Group, and three scheduled-query rules; `devops-rg` remains empty and untouched.
- Required Azure resource providers now report `Registered`.
- The GitHub fork is public, `main` is unprotected, and GitHub CLI is authenticated as its administrator. Source is pushed through `82b814e`; its expected Actions secret/variable names are configured. OIDC uses the repository's live immutable subject prefix, not the legacy name-only subject.
- The default kubeconfig points to an unrelated GKE production-named context. Never run this project's kubectl/Helm commands against it. Use a dedicated, ignored project kubeconfig file once AKS exists.

## What was last done?

The reviewed Terraform plan applied successfully (13 added, 0 changed, 0 destroyed). ACR and AKS baseline checks passed through the dedicated kubeconfig. Helm's image repository was changed to the created ACR while retaining `bootstrap`. A dedicated Entra CI identity, exact GitHub OIDC federation, ACR-scoped `AcrPush`, and the GitHub configuration names were then created.

## What command/action comes next?

1. Install Argo CD with Helm into `argocd` using only the dedicated kubeconfig and wait for core pods.
2. Commit a harmless app change to trigger CI, verify the immutable image/tag and bot's one-field GitOps commit, then apply the Argo Application.

## What human input is needed?

- Confirm the notification when the controlled alert test occurs.
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
