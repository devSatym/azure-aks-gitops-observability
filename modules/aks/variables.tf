variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "aks_name" {
  type = string
}

variable "dns_prefix" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "node_count" {
  type = number
}

variable "node_vm_size" {
  type = string
}

variable "network_plugin_mode" {
  type     = string
  default  = null
  nullable = true
}

variable "pod_cidr" {
  type     = string
  default  = null
  nullable = true
}

variable "node_max_pods" {
  type     = number
  default  = null
  nullable = true
}

variable "log_analytics_workspace_id" {
  type = string
}

variable "tags" {
  type = map(string)
}
