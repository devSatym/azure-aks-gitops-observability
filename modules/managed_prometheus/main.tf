resource "azurerm_monitor_workspace" "this" {
  name                = "amw-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# The AKS managed metrics add-on uses this endpoint and DCR independently of
# the existing Container Insights DCR/DCRA. Keeping both paths separate makes
# metrics migration reversible and preserves the v1 platform alerting path.
resource "azurerm_monitor_data_collection_endpoint" "this" {
  name                = "msprom-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "Linux"
  tags                = var.tags
}

resource "azurerm_monitor_data_collection_rule" "this" {
  name                        = "msprom-${var.name_prefix}"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.this.id
  kind                        = "Linux"
  description                 = "DCR for AKS Azure Managed Prometheus metrics."
  tags                        = var.tags

  destinations {
    monitor_account {
      name               = "prometheusMonitorAccount"
      monitor_account_id = azurerm_monitor_workspace.this.id
    }
  }

  data_flow {
    streams      = ["Microsoft-PrometheusMetrics"]
    destinations = ["prometheusMonitorAccount"]
  }

  data_sources {
    prometheus_forwarder {
      name    = "PrometheusDataSource"
      streams = ["Microsoft-PrometheusMetrics"]
    }
  }
}

resource "azurerm_monitor_data_collection_rule_association" "this" {
  name                    = "msprom-${var.aks_name}"
  target_resource_id      = var.aks_id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.this.id
  description             = "Association for AKS Azure Managed Prometheus metrics."
}
