resource "azurerm_dashboard_grafana" "this" {
  count = var.enabled ? 1 : 0

  name                = "amg-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku                   = "Standard"
  sku_size              = "X1"
  grafana_major_version = "12"

  api_key_enabled                   = false
  deterministic_outbound_ip_enabled = false
  public_network_access_enabled     = true

  azure_monitor_workspace_integrations {
    resource_id = var.azure_monitor_workspace_id
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# The managed Grafana identity gets only the data-plane read permissions it
# needs for the Azure Monitor Workspace and Application Insights views.
resource "azurerm_role_assignment" "azure_monitor_workspace_reader" {
  count = var.enabled ? 1 : 0

  scope                            = var.azure_monitor_workspace_id
  role_definition_name             = "Monitoring Data Reader"
  principal_id                     = azurerm_dashboard_grafana.this[0].identity[0].principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "application_insights_reader" {
  count = var.enabled ? 1 : 0

  scope                            = var.application_insights_id
  role_definition_name             = "Monitoring Reader"
  principal_id                     = azurerm_dashboard_grafana.this[0].identity[0].principal_id
  skip_service_principal_aad_check = true
}
