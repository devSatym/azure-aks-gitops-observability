resource "azurerm_application_insights" "this" {
  name                 = "appi-${var.name_prefix}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  application_type     = "web"
  workspace_id         = var.log_analytics_workspace_id
  daily_data_cap_in_gb = var.daily_data_cap_in_gb

  # Native OTLP ingestion authenticates with Microsoft Entra ID through the
  # collector workload identity. Do not leave local, connection-string based
  # ingestion enabled as a fallback.
  local_authentication_enabled = false

  tags = var.tags
}
