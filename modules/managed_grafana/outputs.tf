output "endpoint" {
  value = try(azurerm_dashboard_grafana.this[0].endpoint, null)
}
