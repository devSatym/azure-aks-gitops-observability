resource "azurerm_monitor_action_group" "this" {
  name                = "ag-${var.name_prefix}-aks"
  resource_group_name = var.resource_group_name
  short_name          = "aksalerts"

  email_receiver {
    name                    = "platform-email"
    email_address           = var.alert_email
    use_common_alert_schema = true
  }

  tags = var.tags
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "aks_node_not_ready" {
  name                = "alert-${var.name_prefix}-aks-node-not-ready"
  resource_group_name = var.resource_group_name
  location            = var.location

  scopes               = [var.log_analytics_workspace_id]
  description          = "Alert when any AKS node is not Ready."
  severity             = 2
  enabled              = true
  evaluation_frequency = "PT5M"
  window_duration      = "PT15M"

  criteria {
    query = <<-KQL
      KubeNodeInventory
      | where TimeGenerated > ago(15m)
      | summarize arg_max(TimeGenerated, *) by Computer
      | where Status != "Ready"
    KQL

    time_aggregation_method = "Count"
    operator                = "GreaterThan"
    threshold               = 0

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.this.id]
  }

  tags = var.tags
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "aks_pod_failed" {
  name                = "alert-${var.name_prefix}-aks-pod-failed"
  resource_group_name = var.resource_group_name
  location            = var.location

  scopes               = [var.log_analytics_workspace_id]
  description          = "Alert when AKS pods are Failed or in CrashLoopBackOff."
  severity             = 2
  enabled              = true
  evaluation_frequency = "PT5M"
  window_duration      = "PT15M"

  criteria {
    query = <<-KQL
      KubePodInventory
      | where TimeGenerated > ago(15m)
      | where PodStatus == "Failed" or ContainerStatus contains "CrashLoopBackOff"
    KQL

    time_aggregation_method = "Count"
    operator                = "GreaterThan"
    threshold               = 0

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.this.id]
  }

  tags = var.tags
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "aks_pod_restarts" {
  name                = "alert-${var.name_prefix}-aks-pod-restarts"
  resource_group_name = var.resource_group_name
  location            = var.location

  scopes               = [var.log_analytics_workspace_id]
  description          = "Alert when AKS pods restart frequently."
  severity             = 3
  enabled              = true
  evaluation_frequency = "PT5M"
  window_duration      = "PT15M"

  criteria {
    query = <<-KQL
      KubePodInventory
      | where TimeGenerated > ago(15m)
      | summarize RestartCount=max(ContainerRestartCount) by Name, Namespace
      | where RestartCount > 2
    KQL

    time_aggregation_method = "Count"
    operator                = "GreaterThan"
    threshold               = 0

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.this.id]
  }

  tags = var.tags
}