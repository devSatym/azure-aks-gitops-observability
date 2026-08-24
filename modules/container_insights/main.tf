locals {
  container_insights_streams = [
    "Microsoft-ContainerLog",
    "Microsoft-ContainerLogV2",
    "Microsoft-KubeEvents",
    "Microsoft-KubePodInventory",
    "Microsoft-KubeNodeInventory",
    "Microsoft-KubePVInventory",
    "Microsoft-KubeServices",
    "Microsoft-KubeMonAgentEvents",
    "Microsoft-InsightsMetrics",
    "Microsoft-ContainerInventory",
    "Microsoft-ContainerNodeInventory",
    "Microsoft-Perf",
  ]
}

# AKS enables the managed-identity monitoring add-on, while this DCR/DCRA pair
# defines which Container Insights streams are sent to the Log Analytics
# workspace. Azure's current MSI onboarding template requires both resources.
resource "azurerm_monitor_data_collection_rule" "this" {
  name                = "MSCI-${var.location}-${var.aks_name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  description         = "DCR for Azure Monitor Container Insights"
  tags                = var.tags

  destinations {
    log_analytics {
      name                  = "ciworkspace"
      workspace_resource_id = var.log_analytics_workspace_id
    }
  }

  data_flow {
    streams      = local.container_insights_streams
    destinations = ["ciworkspace"]
  }

  data_sources {
    extension {
      name           = "ContainerInsightsExtension"
      extension_name = "ContainerInsights"
      streams        = local.container_insights_streams
      extension_json = jsonencode({
        dataCollectionSettings = {
          interval               = "1m"
          namespaceFilteringMode = "Off"
          namespaces             = []
          enableContainerLogV2   = true
        }
      })
    }
  }
}

resource "azurerm_monitor_data_collection_rule_association" "this" {
  name                    = "ContainerInsightsExtension"
  target_resource_id      = var.aks_id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.this.id
  description             = "Association of the Container Insights DCR with this AKS cluster."
}
