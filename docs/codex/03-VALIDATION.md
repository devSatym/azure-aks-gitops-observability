# Validation Matrix

Only commands and outcomes observed in this environment receive `PASS`.

| Test | Expected | Actual | Status | Evidence |
| --- | --- | --- | --- | --- |
| Repository audit | All implementation areas inspected before changes | Completed on 2026-08-23 | PASS | `00-REPO-AUDIT.md` |
| Terraform CLI | Compatible local Terraform available | Terraform 1.15.8 installed | PASS | command output recorded in project status |
| Helm CLI | Helm available for chart checks | Helm 3.21.2 installed | PASS | command output recorded in project status |
| Terraform fmt | No formatting changes required | `terraform fmt -check -recursive` succeeded | PASS | command output, 2026-08-23 |
| Terraform init, backend disabled | Provider initialization succeeds | `terraform init -backend=false` installed AzureRM 4.81.0 and Random 3.9.0 | PASS | `.terraform.lock.hcl` |
| Terraform validate | Configuration validates | `terraform validate` succeeded | PASS | command output, 2026-08-23 |
| Terraform plan/apply | Expected infrastructure created | Not run; Azure CLI unavailable | BLOCKED | `02-PROJECT-STATUS.md` |
| ACR | Registry exists and is available | Not run | BLOCKED | Azure access required |
| AKS / ACR pull | Nodes Ready and kubelet can pull | Not run | BLOCKED | Azure access required |
| GitHub OIDC | Passwordless Azure login succeeds | Not run | BLOCKED | Entra/GitHub configuration required |
| Docker build | Application image builds | `docker build --tag azure-webapp:local-validation ./app` succeeded | PASS | local image inspection, 2026-08-23 |
| ACR SHA image | Immutable SHA image exists in ACR | Not run | BLOCKED | ACR/OIDC required |
| GitOps workflow structure | CI has OIDC + ACR push + deterministic `image.tag` update; no AKS deployment command | YAML parser and isolated update script passed; no direct deploy command found in CI source | PASS | `.github/workflows/deploy-aks.yml` |
| GitOps commit | CI changes only Helm `image.tag` in a real GitHub run | Not run | BLOCKED | workflow/GitHub access required |
| Helm chart | Lint/render succeeds | `helm lint` passed; `helm template` rendered one Service and one two-replica Deployment | PASS | command output, 2026-08-23 |
| Argo CD | Application Synced and Healthy | Not run | BLOCKED | AKS/Argo required |
| Application | LoadBalancer responds | Not run | BLOCKED | AKS required |
| Drift correction | Argo restores desired replicas | Not run | BLOCKED | AKS/Argo required |
| Container Insights | Cluster/workload telemetry appears | Not run | BLOCKED | deployed AKS and ingestion wait required |
| KQL | Query returns actual data | Not run | BLOCKED | Log Analytics required |
| Azure Monitor rules | Three configured rules/action group exist | Not run | BLOCKED | Terraform apply required |
| Fired alert / email | Controlled failure fires and notifies | Not run | BLOCKED | data ingestion and alert email required |
| Prometheus / Grafana | Stack healthy and dashboard populated | Not run | BLOCKED | AKS required |
| Secret hygiene | No local secret/state/backend configuration tracked | Pending final pre-commit scan | NOT RUN | — |
