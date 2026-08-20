output "workspace_id" {
  value = azurerm_monitor_workspace.this.id
}

output "workspace_name" {
  value = azurerm_monitor_workspace.this.name
}

output "data_collection_rule_id" {
  value = azurerm_monitor_data_collection_rule.this.id
}
