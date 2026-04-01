output "acr_id" {
  value = azurerm_container_registry.this.id
}

output "acr_name" {
  value = azurerm_container_registry.this.name
}

output "login_server" {
  value = azurerm_container_registry.this.login_server
}