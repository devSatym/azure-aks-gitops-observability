# Handoff

## Where are we?

The project has a live, evidence-backed first delivery and is waiting only on Azure-native telemetry ingestion before controlled alert validation. Terraform applied the reviewed plan as 13 adds with no changes or destruction; CI used OIDC to publish a SHA image and update Git; Argo deployed it and proved self-heal; Prometheus/Grafana baseline checks pass.

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
- Argo CD 3.5.1 is deployed from Helm chart 10.4.0. The `azure-webapp` Application is `Synced`/`Healthy` at bot revision `751d2c4`, deploying `azure-webapp:9d37a77` with two Ready pods and a working LoadBalancer response.
- A deliberate live scale to four replicas became `OutOfSync`; Argo restored the Git-defined two replicas in 28 seconds without a Git change.
- `kube-prometheus-stack` 88.5.4 is deployed in `monitoring`: Prometheus is healthy with 18/18 active targets, and Grafana is healthy with its supplied Kubernetes dashboards.

## What remains unverified?

- Container Insights ingestion and real KQL result records; a controlled failed-pod alert and recipient notification confirmation; fresh owner-captured screenshots.
- README, historical phase guides, architecture image, and screenshot assets are inherited/stale; do not treat them as evidence.

## Important external facts

- The active Azure subscription was inspected without a subscription switch. It has the dedicated state backend plus `rg-aksops-dev-n8bo7j`, `aks-aksops-dev-n8bo7j`, `acraksopsdevn8bo7j`, `law-aksops-dev-n8bo7j`, VNet/subnet, Action Group, and three scheduled-query rules; `devops-rg` remains empty and untouched.
- Required Azure resource providers now report `Registered`.
- The GitHub fork is public, `main` is unprotected, and GitHub CLI is authenticated as its administrator. First delivery source `9d37a77` promoted to bot commit `751d2c4`; OIDC uses the repository's live immutable subject prefix, not the legacy name-only subject.
- The default kubeconfig points to an unrelated GKE production-named context. Never run this project's kubectl/Helm commands against it. Use a dedicated, ignored project kubeconfig file once AKS exists.

## What was last done?

Argo CD was installed through the dedicated kubeconfig and validated before the Application existed. The first app commit completed OIDC login, ACR push, and a one-field GitOps update. After its real SHA tag existed, Argo synchronized a two-pod Deployment and LoadBalancer response. The reversible self-heal test and Prometheus/Grafana API checks then passed. Initial Log Analytics queries are empty while new-workspace telemetry ingests; no alert test has run.

## What command/action comes next?

1. Re-run direct `KubePodInventory` and `KubeNodeInventory` queries after ingestion.
2. Only after a current record appears, create/delete one disposable failed pod, verify the scheduled query fires, and request recipient confirmation without recording the email.

## What human input is needed?

- Confirm the notification when the controlled alert test occurs.
- Capture the fresh checklist items in `docs/screenshots/README.md`; inherited images cannot be used as proof.

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
