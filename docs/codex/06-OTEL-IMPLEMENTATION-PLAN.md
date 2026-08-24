# OpenTelemetry Demo migration plan

## Scope and baseline

This feature branch evolves the validated v1 baseline without rebuilding it.
The existing `azure-webapp` remains the small platform canary for the proven
GitHub Actions → OIDC → ACR SHA image → Git commit → Argo CD path. The official
OpenTelemetry Demo becomes the primary workload in `otel-demo`.

## Audit outcome

- The live cluster has two `Standard_D2s_v5` nodes (3.8 allocatable CPU, about
  14 GiB allocatable memory, and 60 pod slots total).
- Before the migration it had 39 running pods and roughly 1.84 CPU / 2.76 GiB
  of scheduled requests. The temporary coexistence of the demo, the managed
  metrics agents, and `kube-prometheus-stack` would exceed the available pod
  headroom.
- The desired three-node `Standard_D2s_v5` overlap capacity was rejected by
  Azure because the subscription's Central India regional and DSv5 vCPU quotas
  are both fully consumed (4 of 4 vCPUs). The implemented migration therefore
  retains two nodes and retires `kube-prometheus-stack` after managed metrics
  validation, before the OTel Demo is reconciled. Three nodes remain the
  recommended setting after a quota increase if overlap/headroom is needed.
- The full pinned upstream demo renders 22 workload pods. The two-node cluster
  permits 60 pods and its post-retirement platform baseline uses 42, so the
  wrapper disables five ancillary, dependency-free components (`accounting`,
  `ad`, `fraud-detection`, `image-provider`, and `telemetry-docs`). The
  resulting 17-pod demo retains the storefront, checkout, messaging, load
  generation, Collector, and multi-language service paths while leaving one
  slot for recovery. Restore the full chart only after capacity increases.
- Container Insights, its DCR/DCRA, the existing Log Analytics workspace, and
  the established KQL alert rules are retained.

## Target data paths

1. Container Insights DCR/DCRA → existing Log Analytics workspace for
   Kubernetes inventory, logs, and platform alerts.
2. AKS Managed Prometheus DCE/DCR/DCRA → Azure Monitor workspace for
   Prometheus metrics and PromQL.
3. OTel Demo Collector → native Azure Monitor OTLP DCE/DCR → existing Log
   Analytics workspace (traces and logs) and Azure Monitor workspace (metrics),
   with a workspace-based Application Insights resource for application views.

The collector uses AKS workload identity and a DCR-scoped `Monitoring Metrics
Publisher` role. A Terraform-managed ServiceAccount and ConfigMap carry the
identity binding and non-secret endpoint configuration; no connection string or
instrumentation key is committed to Git or injected into the workload.

The DCR maps its detailed `Microsoft-OTel-*` streams to Azure destinations,
but the native OTLP HTTP request URLs use the case-sensitive aggregate
`Microsoft-OTLP-Traces` and `Microsoft-OTLP-Logs` stream names. The wrapper
uses a desired-state revision annotation so any Terraform-owned endpoint change
causes Argo CD to roll the collector and reload its environment.

## Intentional ARM exception

AzureRM 4.81.0 models normal DCRs but not the native OTLP DCR fields required
by Azure Monitor (`references.applicationInsights`, OTLP data sources, and
direct data sources). The only ARM usage is a narrow
`azurerm_resource_group_template_deployment` for that unsupported DCE/DCR
shape. Everything else remains AzureRM-managed. The deployment uses
`Incremental` mode and contains no unrelated resources.

## Delivery sequence

1. Enable AKS workload identity and managed Prometheus, create Application
   Insights, Azure Monitor workspace, DCE/DCR resources, and the collector
   identity/config handoff through Terraform.
2. Render the pinned upstream OTel Demo wrapper with bundled Jaeger,
   Prometheus, Grafana, and OpenSearch disabled. Retain the built-in load
   generator and a Collector gateway with Kubernetes metadata enrichment.
3. Push the feature branch and bootstrap a separate Argo CD Application that
   tracks this branch for pre-merge validation. The existing canary continues
   to track `main`.
4. Validate collector health, generated traffic, Container Insights records,
   Application Insights tables, native OTLP ingestion, and managed Prometheus
   queries.
5. Remove the self-hosted `kube-prometheus-stack` only after the managed metric
   path is proven. Do not remove its CRDs unless a later audit proves they have
   no consumers.
6. Keep Azure Managed Grafana as an explicit, disabled-by-default Terraform
   option: Standard is the only current new-workspace tier and has recurring
   cost. The Azure portal and PromQL remain the validated managed path without
   silently creating that optional billable service.

## Verification checklist

- `terraform fmt -check`, `terraform validate`, and a reviewed plan show only
  the intended migration resources with the quota-compatible two-node pool.
- `helm dependency build`, `helm lint`, and `helm template` succeed for the
  wrapper and render no Jaeger, Prometheus, Grafana, or OpenSearch resources.
- Argo CD reports `otel-demo` Synced and Healthy; all demo components,
  collector, and load generator are Ready.
- Azure Monitor shows Container Insights data for `otel-demo`; Application
  Insights shows requests/dependencies/traces; managed Prometheus returns a
  non-empty PromQL result.
- A controlled, native OTel Demo fault produces visible failure telemetry and
  is removed afterward.
- After managed-path validation, no in-cluster self-hosted Prometheus, Grafana,
  Jaeger, OpenSearch, Loki, Tempo, or equivalent backend remains.
