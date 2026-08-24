resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/part-of" = "opentelemetry-demo"
    }
  }
}

# Helm is configured to use this pre-created ServiceAccount. Terraform owns the
# dynamic workload-identity annotation, so Argo CD never needs a cloud identity
# value committed to a Helm values file.
resource "kubernetes_service_account_v1" "collector" {
  metadata {
    name      = var.collector_service_account_name
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    annotations = {
      "azure.workload.identity/client-id" = var.collector_client_id
    }
  }
}

# These endpoint URLs identify the native OTLP DCR but are not credentials.
# The collector receives the values through envFrom rather than Git-managed
# chart values, keeping cloud-specific configuration separate from workload
# desired state.
resource "kubernetes_config_map_v1" "azure_otlp" {
  metadata {
    name      = var.endpoint_config_map_name
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }

  data = {
    AZURE_MONITOR_TRACES_ENDPOINT  = var.traces_endpoint
    AZURE_MONITOR_LOGS_ENDPOINT    = var.logs_endpoint
    AZURE_MONITOR_METRICS_ENDPOINT = var.metrics_endpoint
  }

  depends_on = [kubernetes_service_account_v1.collector]
}
