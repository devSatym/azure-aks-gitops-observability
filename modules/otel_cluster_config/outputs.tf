output "namespace" {
  value = kubernetes_namespace_v1.this.metadata[0].name
}

output "endpoint_config_map_name" {
  value = kubernetes_config_map_v1.azure_otlp.metadata[0].name
}
