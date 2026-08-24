# Project Status

## Current phase

Azure-native OpenTelemetry migration is complete and has been validated live. The
OpenTelemetry Demo is the primary workload; the existing `azure-webapp`
continues as the small CI → ACR → GitOps canary.

## Current live state

| Area | State |
| --- | --- |
| AKS | Two Ready `Standard_D2s_v5` nodes, Azure CNI, 60 pod slots |
| Capacity | 59 running pods after the migration; do not add replicas or backends until quota increases |
| Canary | `azure-webapp` remains Argo-managed and Healthy with two Ready replicas |
| Primary workload | `opentelemetry-demo` is Argo `Synced`/`Healthy`; all 17 retained demo deployments are Ready |
| Public demo endpoint | `frontend-proxy` LoadBalancer returned HTTP 200 |
| Metrics | AKS Managed Prometheus returns current `otel-demo` metrics through PromQL |
| Trace/log telemetry | Native OTLP records continuously arrive in `OTelSpans`, `OTelEvents`, `OTelLogs`, and `OTelResources` |
| Legacy stack | `kube-prometheus-stack` has been removed; Prometheus Operator CRDs are intentionally retained |
| Platform alerts | Container Insights, the three scheduled-query rules, Action Group, KQL evidence, and recipient-confirmed alert delivery remain live |

## Completed migration work

- Added workspace-based Application Insights with local authentication disabled.
- Enabled AKS workload identity and created a collector user-assigned managed
  identity, federated credential, and DCR-scoped `Monitoring Metrics Publisher`
  assignment.
- Added an Azure Monitor workspace plus a managed Prometheus DCE, DCR, and AKS
  DCR association.
- Added a narrow Terraform ARM deployment for the native OTLP DCE/DCR shape
  that AzureRM 4.81.0 cannot represent.
- Added Terraform-owned `otel-demo` namespace, workload-identity collector
  ServiceAccount, and non-secret native-OTLP endpoint ConfigMap.
- Added a Helm wrapper around the pinned official OpenTelemetry Demo chart
  `0.41.0`; its local Jaeger, Prometheus, Grafana, and OpenSearch backends are
  disabled.
- Kept the core demo traffic paths and disabled only five ancillary components
  so the workload fits the two-node, 60-pod cluster.
- Confirmed managed Prometheus before removing only the
  `kube-prometheus-stack` Helm release. The empty `monitoring` namespace has
  no running legacy workload; the 12 operator CRDs remain for compatibility.
- Corrected the collector's trace/log request URLs from the DCR's detailed
  `Microsoft-OTel-*` data-flow names to the case-sensitive aggregate
  `Microsoft-OTLP-Traces` and `Microsoft-OTLP-Logs` request streams. Metrics
  continue to use `Custom-Metrics-Otel`.
- Added a desired-state pod annotation so a Terraform endpoint ConfigMap change
  causes Argo CD to roll the collector and reload the handoff values.
- Validated a short, controlled `paymentFailure` scenario, then restored it:
  five distinct payment traces showed error spans during the fault window and
  subsequent charges were successful after recovery.

## Validation evidence

- `terraform fmt -check -recursive`, `terraform validate`, and the final
  remote-state plan passed with no pending changes.
- The wrapper passed `helm lint`, rendered cleanly with the four local
  observability backends absent, and passed Kubernetes server-side dry run.
- The live collector had no recurring HTTP 400, drop, or exporter-failure log
  entries after the native endpoint correction.
- At 2026-08-24T06:08Z, a three-minute Log Analytics query returned 9,852
  `OTelSpans`, 3,125 `OTelEvents`, 3,159 `OTelLogs`, and 839
  `OTelResources` records from the demo.
- Managed Prometheus returned current
  `{__name__="demo.payment.transactions"}` USD/CAD series labelled
  `service.name=payment` and `k8s.namespace.name=otel-demo`.
- During the controlled failure window, native telemetry recorded 10 payment
  failure logs and 13 error spans; the flag configuration was restored and the
  new flagd pod confirmed the default `off` setting.
- Classical workspace Application Insights tables such as `AppRequests` and
  `AppDependencies` were empty during validation. This is expected for the
  native OTLP DCR path; use the `OTel*` tables as the evidence target.

## Azure resources in scope

Alongside the existing resource group, VNet/subnet, AKS, ACR, Log Analytics
workspace, Container Insights DCR/DCRA, alerts, and canary application, the
migration adds:

- a workspace-based Application Insights resource;
- an Azure Monitor workspace;
- managed Prometheus DCE, DCR, and AKS DCR association;
- native OTLP DCE and DCR;
- a collector user-assigned identity, federated credential, and scoped role
  assignment;
- Terraform-owned `otel-demo` namespace, ServiceAccount, and ConfigMap; and
- the Argo CD `opentelemetry-demo` Application and Helm wrapper.

Azure Managed Grafana remains an explicit disabled-by-default Terraform option;
no billable dashboard service was created.

## Remaining work

- Capture fresh owner screenshots using
  [`docs/screenshots/README.md`](../screenshots/README.md). Inherited image
  files remain non-evidence.
- Obtain regional DSv5 quota before restoring the full demo profile, adding
  replicas, or reintroducing any in-cluster backend.
- Keep the OTel Application on the released Git revision; do not use a direct
  Helm release or raw-manifest workaround.

## Safety notes

- The default kubeconfig targets an unrelated GKE context. All project
  Kubernetes and Helm commands must use
  `/tmp/azure-aks-gitops-observability.kubeconfig` (or another explicit,
  dedicated project file).
- Do not run `terraform destroy` or remove the remote state backend without
  separate explicit approval.
- The controlled payment-failure procedure is deliberately not a routine
  GitOps toggle: the pinned child chart embeds the flagd configuration and
  flagd must restart to copy it. Keep it as an operator-only, brief test until
  a safe chart overlay and rollout strategy are designed.

## Last updated

2026-08-24, Asia/Kolkata — native Azure OTLP, managed Prometheus, and the
capacity-safe OpenTelemetry Demo migration are live validated.
