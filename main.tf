resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

locals {
  name_prefix = "${var.project_name}-${var.environment}-${random_string.suffix.result}"

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Owner       = "devSatym"
  }
}

module "resource_group" {
  source = "./modules/resource_group"

  name     = "rg-${local.name_prefix}"
  location = var.location
  tags     = local.tags
}

module "network" {
  source = "./modules/network"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name_prefix         = local.name_prefix
  tags                = local.tags
}

module "acr" {
  source = "./modules/acr"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  acr_name            = replace("acr${var.project_name}${var.environment}${random_string.suffix.result}", "-", "")
  tags                = local.tags
}

module "monitoring" {
  source = "./modules/monitoring"

  name_prefix         = local.name_prefix
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  tags                = local.tags
}

module "alerts" {
  source = "./modules/alerts"

  name_prefix                = local.name_prefix
  location                   = module.resource_group.location
  resource_group_name        = module.resource_group.name
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  alert_email                = var.alert_email
  tags                       = local.tags
}

module "aks" {
  source = "./modules/aks"

  resource_group_name        = module.resource_group.name
  location                   = module.resource_group.location
  aks_name                   = "aks-${local.name_prefix}"
  dns_prefix                 = "aks-${var.project_name}-${random_string.suffix.result}"
  subnet_id                  = module.network.aks_subnet_id
  node_count                 = var.node_count
  node_vm_size               = var.node_vm_size
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  tags                       = local.tags
}

module "container_insights" {
  source = "./modules/container_insights"

  resource_group_name        = module.resource_group.name
  location                   = module.resource_group.location
  aks_name                   = module.aks.aks_name
  aks_id                     = module.aks.aks_id
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  tags                       = local.tags
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                            = module.acr.acr_id
  role_definition_name             = "AcrPull"
  principal_id                     = module.aks.kubelet_identity_object_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "aks_network_contributor" {
  scope                            = module.network.aks_subnet_id
  role_definition_name             = "Network Contributor"
  principal_id                     = module.aks.cluster_identity_principal_id
  skip_service_principal_aad_check = true
}
