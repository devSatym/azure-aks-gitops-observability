variable "name_prefix" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "application_insights_id" {
  type = string
}

variable "azure_monitor_workspace_id" {
  type = string
}

variable "log_analytics_workspace_id" {
  type = string
}

variable "oidc_issuer_url" {
  type = string
}

variable "namespace" {
  type = string
}

variable "collector_service_account_name" {
  type = string
}

variable "tags" {
  type = map(string)
}
