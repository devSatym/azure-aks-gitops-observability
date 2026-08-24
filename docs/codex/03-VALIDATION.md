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
| AKS custom-network role design | Control-plane identity has least-privilege subnet access | Terraform declares subnet-scoped `Network Contributor`; live role not created yet | PASS (static) | `main.tf`, `modules/aks/outputs.tf` |
| Alert query semantics | CrashLoop/restart query matches current table semantics | Query uses `ContainerStatusReason` and 15-minute restart delta; no live data yet | PASS (static) | `modules/alerts/main.tf`, `04-DECISIONS.md` |
| Helm chart | Lint/render succeeds | Helm 3.21.2 lint passes; template renders one Service and one two-replica Deployment | PASS | command output, 2026-08-24 |
| Docker build | Application image builds locally | Passed in the prior local validation recorded 2026-08-23; no source change since | PASS | `02-PROJECT-STATUS.md` historical command record |
| GitOps workflow structure | OIDC + ACR push + deterministic one-field update; no direct cluster deploy | Source review confirms expected permissions/steps and no AKS/Helm/Argo deploy command | PASS (static) | `.github/workflows/deploy-aks.yml` |
| Remote source parity | Fork sees current local migration | Seven reviewed commits pushed to `origin/main` at `4b71395` | PASS | `git push origin main`, 2026-08-24 |
| Azure account inventory | Active subscription is inspected without a switch | One enabled/default subscription inspected; project resources absent | PASS | Azure CLI output, 2026-08-24 |
| Azure provider registration | Required resource providers available | Storage, Network, Compute, Managed Identity, Container Service, Container Registry, Operational Insights, Operations Management, and Insights report `Registered` | PASS | Azure CLI output, 2026-08-24 |
| Terraform remote backend | Owner-controlled Entra-authenticated Azure Storage state works | Private `tfstate` container, Blob Data Contributor role, and `terraform init -reconfigure` succeed without a storage key | PASS | `02-PROJECT-STATUS.md`, Azure CLI/Terraform output |
| Terraform plan/apply | Expected infrastructure created without unexpected destroys | Not run | BLOCKED | backend, inputs, provider registration pending |
| ACR | Registry exists; admin disabled; image tag is present | Not run | BLOCKED | Terraform/OIDC required |
| AKS / ACR pull | Nodes Ready and workload can pull image | Not run | BLOCKED | Terraform/OIDC/GitOps required |
| Isolated kubectl access | Project commands target only the new AKS cluster | Not run; default context is intentionally unsafe/unrelated | BLOCKED | ADR-013 |
| GitHub OIDC | Passwordless Azure login succeeds | No Entra federation/secrets configured | BLOCKED | Azure/GitHub configuration required |
| GitOps commit | CI changes only Helm `image.tag` in a real run | Not run | BLOCKED | OIDC/ACR configuration required |
| Argo CD | Core pods healthy; Application Synced and Healthy | Not installed; Application intentionally deferred until a real tag exists | BLOCKED | AKS/first CI tag required |
| Application | LoadBalancer responds to intended page | Not run | BLOCKED | Argo/app rollout required |
| Drift correction | Argo restores desired replicas | Not run | BLOCKED | Argo required |
| Container Insights | Cluster/workload telemetry appears | Not run | BLOCKED | AKS/ingestion required |
| KQL | Current schema query returns actual records | Not run | BLOCKED | Log Analytics ingestion required |
| Azure Monitor rules | Three rules and Action Group exist | Not run | BLOCKED | Terraform apply required |
| Fired alert / email | Controlled failed pod fires and notifies | Not run | BLOCKED | telemetry/rules/recipient confirmation required |
| Prometheus / Grafana | Stack healthy and dashboard populated | Not run | BLOCKED | AKS required |
| Screenshot evidence | Fresh screenshots map to observed tests | Not run | BLOCKED | live validation and owner capture required |
| Secret hygiene | No secret/state/local backend config is tracked | Final scan pending commit/push | NOT RUN | — |
