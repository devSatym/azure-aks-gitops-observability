variable "enabled" {
  type = bool
}

variable "name_prefix" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "azure_monitor_workspace_id" {
  type = string
}

variable "application_insights_id" {
  type = string
}

variable "tags" {
  type = map(string)
}
