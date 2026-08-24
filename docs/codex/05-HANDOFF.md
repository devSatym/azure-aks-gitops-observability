# Handoff

## Where are we?

The Azure-native OpenTelemetry migration is complete and live validated. The
official OpenTelemetry Demo is the primary AKS workload in `otel-demo`; the
existing `azure-webapp` remains the CI → ACR → GitOps canary. Argo CD owns both
Helm releases.

The primary workload is Synced/Healthy with 17 retained demo deployments Ready,
the `frontend-proxy` LoadBalancer returns HTTP 200, managed Prometheus returns
current metrics, and native OTLP telemetry continuously reaches Log Analytics.
The controlled payment-failure test was restored successfully.

## Current operating facts

- The cluster has two `Standard_D2s_v5` nodes and 60 pod slots. Its migration
  footprint is 59 pods, so do not add replicas, restore ancillary components,
  or install an in-cluster observability backend without a quota increase.
- The default kubeconfig points at an unrelated GKE context. Use only the
  dedicated file `/tmp/azure-aks-gitops-observability.kubeconfig` with every
  `kubectl` or Helm command.
- Container Insights remains the platform inventory/log/alert path. Its KQL
  alert rules and recipient-confirmed Action Group email are already validated.
- Managed Prometheus replaces the self-hosted metrics backend. The
  `kube-prometheus-stack` release is gone; its 12 CRDs remain intentionally.
- Native OTel uses the collector's workload identity and DCR-scoped
  `Monitoring Metrics Publisher` RBAC. No Application Insights connection
  string or instrumentation key is committed.
- Native ingestion evidence is in `OTelSpans`, `OTelEvents`, `OTelLogs`,
  and `OTelResources`. The classic `App*` tables were empty and are not the
  validation target for this route.
- Azure Managed Grafana is a disabled-by-default Terraform option, not a live
  service.

## What was last implemented?

1. Added Application Insights, Azure Monitor workspace, managed Prometheus,
   native OTLP DCE/DCR, workload identity, scoped RBAC, and Kubernetes handoff
   resources through Terraform.
2. Added the pinned upstream OpenTelemetry Demo Helm wrapper and its separate
   Argo Application. Local Jaeger, Prometheus, Grafana, and OpenSearch are
   disabled.
3. Reduced the wrapper to a 17-deployment core profile because Central India
   DSv5 quota rejected a third node. The legacy `kube-prometheus-stack` was
   removed only after managed Prometheus produced live data.
4. Diagnosed native trace/log exporter HTTP 400s as a stream-name mismatch:
   detailed DCR streams are `Microsoft-OTel-*`, while HTTP requests must use
   aggregate `Microsoft-OTLP-Traces` and `Microsoft-OTLP-Logs`. Terraform
   updated the endpoint ConfigMap, Argo rolled the collector, and post-rollout
   logs were clean.
5. Verified current `OTel*` rows and managed Prometheus samples. A brief
   `paymentFailure` window produced five failing payment traces, 10 failure
   logs, and 13 error spans, then was restored; subsequent charges were clean.

## What remains?

- Capture fresh owner screenshots from
  [`docs/screenshots/README.md`](../screenshots/README.md). Do not use
  inherited images as current evidence.
- Increase regional DSv5 quota before expanding the demo or its observability
  footprint.
- Keep the OpenTelemetry Demo Application pointed at the released Git desired
  state. Do not run a direct Helm install or change cloud endpoint values in
  Git.

## Safe commands

```bash
PROJECT_KUBECONFIG=/tmp/azure-aks-gitops-observability.kubeconfig

# Refresh only the dedicated project kubeconfig.
az aks get-credentials \
  --resource-group <resource-group> \
  --name <aks-name> \
  --file "$PROJECT_KUBECONFIG"

kubectl --kubeconfig "$PROJECT_KUBECONFIG" get nodes
kubectl --kubeconfig "$PROJECT_KUBECONFIG" get applications \
  --namespace argocd
kubectl --kubeconfig "$PROJECT_KUBECONFIG" get deployments \
  --namespace otel-demo
```

## Is it safe to stop?

Yes. The workload has been restored to its normal flag configuration and Argo is
the intended reconciler. Do not run `terraform destroy`, delete the remote
state backend, remove the OTel Application, or repeat the payment-failure test
without explicit approval and a capacity-aware plan.
