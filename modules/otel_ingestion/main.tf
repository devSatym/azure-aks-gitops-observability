locals {
  data_collection_endpoint_name = "otlp-dce-${var.name_prefix}"
  data_collection_rule_name     = "otlp-dcr-${var.name_prefix}"

  # AzureRM 4.81.0 cannot represent native OTLP directDataSources or the
  # Application Insights reference. This intentionally narrow ARM template is
  # copied from Microsoft's OTLP DCE/DCR reference and is the only non-AzureRM
  # resource shape in this project.
  native_otlp_template = {
    "$schema"      = "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#"
    contentVersion = "1.0.0.0"
    parameters = {
      dataCollectionRuleName = {
        type = "String"
      }
      dataCollectionEndpointName = {
        type = "String"
      }
      location = {
        type = "String"
      }
      applicationInsightsResourceId = {
        type = "String"
      }
      azureMonitorWorkspaceResourceId = {
        type = "String"
      }
      logAnalyticsWorkspaceResourceId = {
        type = "String"
      }
    }
    resources = [
      {
        type       = "Microsoft.Insights/dataCollectionEndpoints"
        apiVersion = "2024-03-11"
        name       = "[parameters('dataCollectionEndpointName')]"
        location   = "[parameters('location')]"
        properties = {
          description = "Data Collection Endpoint for native OTLP telemetry"
          networkAcls = {
            publicNetworkAccess = "Enabled"
          }
        }
      },
      {
        type       = "Microsoft.Insights/dataCollectionRules"
        apiVersion = "2024-03-11"
        name       = "[parameters('dataCollectionRuleName')]"
        location   = "[parameters('location')]"
        dependsOn = [
          "[resourceId('Microsoft.Insights/dataCollectionEndpoints', parameters('dataCollectionEndpointName'))]",
        ]
        properties = {
          description              = "DCR for direct OpenTelemetry Protocol ingestion"
          dataCollectionEndpointId = "[resourceId('Microsoft.Insights/dataCollectionEndpoints', parameters('dataCollectionEndpointName'))]"
          references = {
            applicationInsights = [
              {
                resourceId = "[parameters('applicationInsightsResourceId')]"
                name       = "applicationInsightsResource"
              },
            ]
          }
          # This DCR is called directly by the collector, not associated with
          # an agent. Keep only directDataSources; normal dataSources would be
          # for an AMA/DCRA collection path and are deliberately omitted.
          directDataSources = {
            otelMetrics = [
              {
                streams                      = ["Custom-Metrics-Otel"]
                enrichWithResourceAttributes = ["*"]
                enrichWithReference          = "applicationInsightsResource"
                name                         = "otelMetricsDataSourceDirect"
              },
            ]
            otelLogs = [
              {
                streams                        = ["Microsoft-OTel-Logs"]
                enrichWithResourceAttributes   = ["*"]
                enrichWithReference            = "applicationInsightsResource"
                replaceResourceIdWithReference = true
                name                           = "otelLogsDataSourceDirect"
              },
            ]
            otelTraces = [
              {
                streams = [
                  "Microsoft-OTel-Traces-Spans",
                  "Microsoft-OTel-Traces-Events",
                  "Microsoft-OTel-Traces-Resources",
                ]
                enrichWithResourceAttributes   = ["*"]
                enrichWithReference            = "applicationInsightsResource"
                replaceResourceIdWithReference = true
                name                           = "otelTracesDataSourceDirect"
              },
            ]
          }
          destinations = {
            monitoringAccounts = [
              {
                accountResourceId = "[parameters('azureMonitorWorkspaceResourceId')]"
                name              = "otelAzureMonitorWorkspace"
              },
            ]
            logAnalytics = [
              {
                workspaceResourceId = "[parameters('logAnalyticsWorkspaceResourceId')]"
                name                = "otelLogAnalyticsWorkspace"
              },
            ]
          }
          dataFlows = [
            {
              streams      = ["Custom-Metrics-Otel"]
              destinations = ["otelAzureMonitorWorkspace"]
            },
            {
              streams = [
                "Microsoft-OTel-Logs",
                "Microsoft-OTel-Traces-Spans",
                "Microsoft-OTel-Traces-Events",
                "Microsoft-OTel-Traces-Resources",
              ]
              destinations = ["otelLogAnalyticsWorkspace"]
            },
          ]
        }
      },
    ]
    outputs = {
      dataCollectionRuleId = {
        type  = "String"
        value = "[resourceId('Microsoft.Insights/dataCollectionRules', parameters('dataCollectionRuleName'))]"
      }
      dataCollectionRuleImmutableId = {
        type  = "String"
        value = "[reference(resourceId('Microsoft.Insights/dataCollectionRules', parameters('dataCollectionRuleName')), '2024-03-11', 'full').properties.immutableId]"
      }
      dataCollectionEndpointLogsIngestion = {
        type  = "String"
        value = "[reference(resourceId('Microsoft.Insights/dataCollectionEndpoints', parameters('dataCollectionEndpointName')), '2024-03-11', 'full').properties.logsIngestion.endpoint]"
      }
      dataCollectionEndpointMetricsIngestion = {
        type  = "String"
        value = "[reference(resourceId('Microsoft.Insights/dataCollectionEndpoints', parameters('dataCollectionEndpointName')), '2024-03-11', 'full').properties.metricsIngestion.endpoint]"
      }
    }
  }
}

resource "azurerm_user_assigned_identity" "collector" {
  name                = "id-otel-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_federated_identity_credential" "collector" {
  name                      = "fic-otel-${var.name_prefix}"
  user_assigned_identity_id = azurerm_user_assigned_identity.collector.id
  audience                  = ["api://AzureADTokenExchange"]
  issuer                    = var.oidc_issuer_url
  subject                   = "system:serviceaccount:${var.namespace}:${var.collector_service_account_name}"
}

resource "azurerm_resource_group_template_deployment" "native_otlp" {
  name                = "otel-native-otlp-${var.name_prefix}"
  resource_group_name = var.resource_group_name
  deployment_mode     = "Incremental"
  tags                = var.tags

  template_content = jsonencode(local.native_otlp_template)
  parameters_content = jsonencode({
    dataCollectionRuleName = {
      value = local.data_collection_rule_name
    }
    dataCollectionEndpointName = {
      value = local.data_collection_endpoint_name
    }
    location = {
      value = var.location
    }
    applicationInsightsResourceId = {
      value = var.application_insights_id
    }
    azureMonitorWorkspaceResourceId = {
      value = var.azure_monitor_workspace_id
    }
    logAnalyticsWorkspaceResourceId = {
      value = var.log_analytics_workspace_id
    }
  })
}

locals {
  native_otlp_outputs = jsondecode(azurerm_resource_group_template_deployment.native_otlp.output_content)

  data_collection_rule_id           = local.native_otlp_outputs.dataCollectionRuleId.value
  data_collection_rule_immutable_id = local.native_otlp_outputs.dataCollectionRuleImmutableId.value
  logs_ingestion_endpoint           = local.native_otlp_outputs.dataCollectionEndpointLogsIngestion.value
  metrics_ingestion_endpoint        = local.native_otlp_outputs.dataCollectionEndpointMetricsIngestion.value

  # The DCR maps the individual Microsoft-OTel streams to Azure destinations,
  # while the native OTLP HTTP ingestion contract uses the Microsoft-OTLP
  # aggregate stream names in its request URLs. These names are case-sensitive.
  collector_traces_endpoint  = "${local.logs_ingestion_endpoint}/datacollectionRules/${local.data_collection_rule_immutable_id}/streams/Microsoft-OTLP-Traces/otlp/v1/traces"
  collector_logs_endpoint    = "${local.logs_ingestion_endpoint}/datacollectionRules/${local.data_collection_rule_immutable_id}/streams/Microsoft-OTLP-Logs/otlp/v1/logs"
  collector_metrics_endpoint = "${local.metrics_ingestion_endpoint}/datacollectionRules/${local.data_collection_rule_immutable_id}/streams/Custom-Metrics-Otel/otlp/v1/metrics"
}

resource "azurerm_role_assignment" "collector_otlp_publisher" {
  scope                            = local.data_collection_rule_id
  role_definition_name             = "Monitoring Metrics Publisher"
  principal_id                     = azurerm_user_assigned_identity.collector.principal_id
  skip_service_principal_aad_check = true

  depends_on = [azurerm_resource_group_template_deployment.native_otlp]
}
