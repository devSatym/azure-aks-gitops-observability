output "resource_group_name" {
  value = module.resource_group.name
}

output "aks_cluster_name" {
  value = module.aks.aks_name
}

output "acr_name" {
  value = module.acr.acr_name
}

output "get_credentials_command" {
  value = "az aks get-credentials --resource-group ${module.resource_group.name} --name ${module.aks.aks_name}"
}

output "acr_login_server" {
  value = module.acr.login_server
}