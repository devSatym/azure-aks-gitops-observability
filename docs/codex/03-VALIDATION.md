# Validation Matrix

Only observed commands and outcomes receive `PASS`. Historical v1 evidence is
retained where useful but is explicitly marked as retired when the corresponding
runtime component no longer exists.

| Test | Expected | Actual | Status | Evidence |
| --- | --- | --- | --- | --- |
| Terraform CLI and lock | Compatible Terraform and repeatable provider versions | Terraform 1.15.8; AzureRM 4.81.0 and Random 3.9.0 pinned | PASS | `.terraform.lock.hcl`, 2026-08-24 |
| Terraform formatting and validation | Canonical, valid configuration | `terraform fmt -check -recursive` and `terraform validate` passed after the migration | PASS | command output, 2026-08-24 |
| Remote-state drift plan | Released infrastructure has no unexpected change | Final reviewed remote-state plan reported no changes | PASS | Terraform plan, 2026-08-24 |
| Baseline AKS / ACR | Cluster and registry are usable without registry admin credentials | Two nodes Ready; Basic ACR provisioned with admin disabled | PASS | Azure and Kubernetes API, 2026-08-24 |
| Isolated kubeconfig | Project commands do not touch the unrelated default context | Credentials written only to `/tmp/azure-aks-gitops-observability.kubeconfig`; checks used `--kubeconfig` | PASS | Azure CLI/Kubernetes API, 2026-08-24 |
| GitHub OIDC and canary promotion | CI logs in without a long-lived secret and promotes only Git desired state | First workflow logged in, pushed `azure-webapp:9d37a77`, and bot commit `751d2c4` changed only `image.tag` | PASS | GitHub Actions/Git, 2026-08-24 |
| Canary Argo delivery and self-heal | Argo owns and repairs canary deployment | `azure-webapp` was Synced/Healthy; live scale 2 → 4 returned to 2 in 28 seconds | PASS | Argo/Kubernetes API, 2026-08-24 |
| Container Insights DCR/DCRA | Managed-identity onboarding has the required resources | Terraform created the standard DCR and `ContainerInsightsExtension` association | PASS | Terraform/Azure resource inspection, 2026-08-24 |
| Container Insights/KQL | Current platform inventory reaches Log Analytics | `KubePodInventory` and `KubeNodeInventory` returned current cluster records | PASS | Log Analytics query, 2026-08-24 |
| Azure Monitor alert path | A controlled failure reaches the configured recipient | `ci-alert-test` matched the failed-pod KQL rule; four Sev2 alerts fired and the recipient confirmed email delivery | PASS | Alert Management/KQL/recipient confirmation, 2026-08-24 |
| Self-hosted Prometheus/Grafana v1 baseline | Stack was healthy before migration | Prometheus had 18/18 targets and Grafana had 29 supplied dashboards | PASS (historical; retired) | local port-forward/API checks, 2026-08-24 |
| AKS workload identity | Collector can authenticate to Azure without a secret | AKS OIDC/workload identity, collector UAMI/FIC, annotated ServiceAccount, and DCR-scoped RBAC present | PASS | Terraform/Azure/Kubernetes API, 2026-08-24 |
| Managed Prometheus configuration | Managed metrics path is active | Azure Monitor workspace plus managed Prometheus DCE/DCR/DCRA associated with AKS | PASS | Terraform/Azure resource inspection, 2026-08-24 |
| OTel wrapper render | No local observability backend is rendered | `helm lint` and `helm template` passed; Jaeger, Prometheus, Grafana, and OpenSearch absent; server-side dry run passed | PASS | Helm/Kubernetes API, 2026-08-24 |
| Capacity-safe workload profile | Demo fits quota-constrained AKS | Five ancillary components disabled; 17 demo deployments Ready within 59/60 pod slots | PASS | Helm render/Kubernetes API, 2026-08-24 |
| Legacy metrics retirement | Managed path replaces the in-cluster release | `kube-prometheus-stack` Helm release absent and `monitoring` namespace has no running pods; 12 operator CRDs retained | PASS | Helm/Kubernetes API, 2026-08-24 |
| OTel Argo Application | Argo owns primary workload reconciliation | `opentelemetry-demo` reported Synced/Healthy at `e0a5f0d`; all 17 retained deployments Ready | PASS | Argo/Kubernetes API, 2026-08-24 |
| Primary workload response | Public demo endpoint works | `frontend-proxy` LoadBalancer returned HTTP 200 on port 8080 | PASS | HTTP response, 2026-08-24 |
| Native OTLP endpoint/authentication | Collector accepts and delivers Azure-native signals | Trace/log URLs corrected to `Microsoft-OTLP-*`; after rollout collector logs had no recurring HTTP 400/drop/exporter errors | PASS | authenticated endpoint tests/collector logs, 2026-08-24 |
| Native OTLP Log Analytics ingestion | Demo trace/log data reaches the correct tables | At 06:08Z, 3m query: 9,852 `OTelSpans`, 3,125 `OTelEvents`, 3,159 `OTelLogs`, 839 `OTelResources` | PASS | Log Analytics KQL, 2026-08-24 |
| Native OTLP table semantics | Evidence queries use observed storage schema | `AppRequests`, `AppDependencies`, `AppTraces`, `AppExceptions`, `AppEvents`, and `AppMetrics` were empty; `OTel*` tables held live signals | PASS | Log Analytics KQL, 2026-08-24 |
| Managed Prometheus ingestion | Demo application metrics are queryable | `{__name__="demo.payment.transactions"}` returned current payment USD/CAD series with `service.name=payment` / `k8s.namespace.name=otel-demo`; HTTP and feature-flag metrics also present | PASS | Azure Monitor workspace PromQL, 2026-08-24 |
| Controlled payment failure | A brief real application fault is visible then restored | `paymentFailure` was 100% from 06:03:02Z to 06:03:58Z; five distinct payment traces errored, 10 failure logs and 13 error spans observed; later charges had zero errors | PASS | Log Analytics KQL/Kubernetes logs, 2026-08-24 |
| Screenshot evidence | Fresh captures map to observed tests | Updated owner-capture checklist exists; owner capture is outstanding | PENDING | `docs/screenshots/README.md` |
| Secret hygiene | No state, backend coordinate, credential, or recipient is tracked | Tracked-file/ignore/signature review clean; local sensitive inputs remain ignored | PASS | repository scan, 2026-08-24 |

## Query caveats

- Native OTLP ingestion for this deployment validates through `OTelSpans`,
  `OTelEvents`, `OTelLogs`, and `OTelResources`, not the classic
  Application Insights workspace tables.
- Prometheus metric names containing dots must be selected with
  `{__name__="metric.name"}`; bare metric syntax is invalid for those names.
- The payment fault was restored immediately. Repeating it safely requires a
  chart-owned flag configuration overlay and a constrained flagd rollout; it is
  not a casual values-only toggle.
