output "collector_client_id" {
  value = azurerm_user_assigned_identity.collector.client_id
}

output "collector_traces_endpoint" {
  value = local.collector_traces_endpoint
}

output "collector_logs_endpoint" {
  value = local.collector_logs_endpoint
}

output "collector_metrics_endpoint" {
  value = local.collector_metrics_endpoint
}

output "data_collection_rule_id" {
  value = local.data_collection_rule_id
}
