# Validation Matrix

Only commands and outcomes observed in this environment receive `PASS`. `BLOCKED` means a prerequisite has not yet been met; it is not a successful result.

| Test | Expected | Actual | Status | Evidence |
| --- | --- | --- | --- | --- |
| Repository audit | All implementation areas inspected before changes | Current source, docs, Git, Azure inventory, and GitHub configuration audited on 2026-08-24 | PASS | `00-REPO-AUDIT.md` |
| Terraform CLI and lock | Compatible Terraform and repeatable provider versions | Terraform 1.15.8; AzureRM 4.81.0 and Random 3.9.0 pinned | PASS | `.terraform.lock.hcl`, command output |
| Terraform backend-disabled init | Providers/modules initialize without remote state | `terraform init -backend=false` succeeds | PASS | command output, 2026-08-24 |
| Terraform formatting | Terraform has canonical formatting | `terraform fmt -check -recursive` succeeds after current corrections | PASS | command output, 2026-08-24 |
| Terraform validation | Configuration/provider schema is valid | `terraform validate` succeeds after network-role and alert corrections | PASS | command output, 2026-08-24 |
| Monitoring MSI configuration | Pinned provider accepts managed-identity OMS setting | Configuration validates; current AzureRM docs list the setting | PASS | `modules/aks/main.tf`, `04-DECISIONS.md` |
| AKS custom-network role design | Control-plane identity has least-privilege subnet access | Terraform created subnet-scoped `Network Contributor` for the system identity | PASS | Terraform apply, 2026-08-24 |
| Alert query semantics | CrashLoop/restart query matches current table semantics | Query uses `ContainerStatusReason` and 15-minute restart delta; no live data yet | PASS (static) | `modules/alerts/main.tf`, `04-DECISIONS.md` |
| Helm chart | Lint/render succeeds | Helm 3.21.2 lint passes; template renders one Service and one two-replica Deployment | PASS | command output, 2026-08-24 |
| Docker build / ACR push | Application image builds and publishes an immutable tag | First real workflow built and pushed `azure-webapp:9d37a77` | PASS | GitHub Actions run 32684714941, ACR tag/digest, 2026-08-24 |
| GitOps workflow structure | OIDC + ACR push + deterministic one-field update; no direct cluster deploy | Source review confirms expected permissions/steps and no AKS/Helm/Argo deploy command | PASS (static) | `.github/workflows/deploy-aks.yml` |
| Remote source parity | Fork sees current local migration | First delivery source `9d37a77` and bot promotion `751d2c4` are on `origin/main` | PASS | `git fetch`, `git pull --ff-only`, 2026-08-24 |
| Azure account inventory | Active subscription is inspected without a switch | One enabled/default subscription inspected; project resources now exist | PASS | Azure CLI output, 2026-08-24 |
| Azure provider registration | Required resource providers available | Storage, Network, Compute, Managed Identity, Container Service, Container Registry, Operational Insights, Operations Management, and Insights report `Registered` | PASS | Azure CLI output, 2026-08-24 |
| Terraform remote backend | Owner-controlled Entra-authenticated Azure Storage state works | Private `tfstate` container, Blob Data Contributor role, and `terraform init -reconfigure` succeed without a storage key | PASS | `02-PROJECT-STATUS.md`, Azure CLI/Terraform output |
| Terraform plan | Expected infrastructure change set contains no unexpected destruction | Saved remote-state plan contains 13 creates, 0 changes, and 0 destroys | PASS | `tfplan`, 2026-08-24 |
| Terraform apply | Planned infrastructure is created successfully | 13 added, 0 changed, 0 destroyed | PASS | `terraform apply tfplan`, 2026-08-24 |
| ACR | Registry exists, admin is disabled, and a SHA tag is present | Basic registry provisioned/admin disabled; `azure-webapp:9d37a77` exists with an inspected digest | PASS | Azure CLI, 2026-08-24 |
| AKS baseline | Nodes Ready and Container Insights agents running | Two nodes Ready; system and `ama-logs` pods Running | PASS (baseline) | dedicated-kubeconfig command output, 2026-08-24 |
| Isolated kubectl access | Project commands target only the new AKS cluster | Credentials written only to `/tmp/azure-aks-gitops-observability.kubeconfig`; all checks used `--kubeconfig` | PASS | `az aks get-credentials --file`, 2026-08-24 |
| GitHub OIDC configuration | Federation and least-privilege CI access exist | Dedicated application/SP, live immutable GitHub subject federation, ACR-scoped `AcrPush`, and expected GitHub configuration names exist | PASS (configuration) | Azure CLI/GitHub CLI, 2026-08-24 |
| GitHub OIDC login | Passwordless Azure login succeeds | First workflow Azure login using OIDC succeeded | PASS | GitHub Actions run 32684714941, 2026-08-24 |
| GitOps commit | CI changes only Helm `image.tag` in a real run | Bot commit `751d2c4` changed exactly the one tag line to `9d37a77` | PASS | Git diff / GitHub Actions run, 2026-08-24 |
| Argo CD | Core pods healthy; Application Synced and Healthy | Helm chart 10.4.0 / Argo CD 3.5.1 deployed; Application Synced/Healthy at `751d2c4` | PASS | Helm/Kubernetes API, 2026-08-24 |
| Application | LoadBalancer responds to intended page | Deployment rolled out 2/2; public response contains the delivery marker | PASS | `kubectl rollout status`, HTTP response, 2026-08-24 |
| Drift correction | Argo restores desired replicas | Temporary live scale 2 → 4 became OutOfSync and returned to 2 in 28 seconds | PASS | timestamped Kubernetes/Application status, 2026-08-24 |
| Container Insights | Cluster/workload telemetry appears | `ama-logs` pods Running; first direct workspace queries returned zero pod/node records | PENDING | AKS/KQL command output, 2026-08-24 |
| KQL | Current schema query returns actual records | Initial `KubePodInventory`/`KubeNodeInventory` queries returned empty results | PENDING | Log Analytics query, 2026-08-24 |
| Azure Monitor rules | Three rules and Action Group exist | One enabled Action Group with one receiver and three enabled 5-minute/15-minute rules inspected; recipient omitted | PASS (configuration) | Azure Resource Manager API, 2026-08-24 |
| Fired alert / email | Controlled failed pod fires and notifies | Not run | BLOCKED | telemetry/rules/recipient confirmation required |
| Prometheus / Grafana | Stack healthy and dashboards/metrics are available | Chart 88.5.4 healthy; Prometheus 18/18 targets and workload metric; Grafana health plus 29 supplied dashboards | PASS (baseline) | local-only port-forward/API checks, 2026-08-24 |
| Screenshot evidence | Fresh screenshots map to observed tests | New checklist exists; owner capture is outstanding | PENDING | `docs/screenshots/README.md` |
| Secret hygiene | No secret/state/local backend config is tracked | Final scan pending the next documentation commit/push | NOT RUN | — |
