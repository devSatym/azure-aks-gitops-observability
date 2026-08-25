variable "name_prefix" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "log_analytics_workspace_id" {
  type = string
}

variable "daily_data_cap_in_gb" {
  type = number
}

variable "tags" {
  type = map(string)
}
