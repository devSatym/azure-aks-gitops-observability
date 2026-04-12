output "action_group_id" {
  value = azurerm_monitor_action_group.this.id
}

output "node_not_ready_alert_id" {
  value = azurerm_monitor_scheduled_query_rules_alert_v2.aks_node_not_ready.id
}