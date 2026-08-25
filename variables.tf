variable "location" {
  description = "Azure region"
  type        = string
  default     = "centralindia"
}

variable "project_name" {
  description = "Project short name"
  type        = string
  default     = "aksops"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "node_count" {
  description = "AKS node count. Keep the default within the currently available regional vCPU quota."
  type        = number
  default     = 2
}

variable "node_vm_size" {
  description = "AKS node VM size"
  type        = string
  default     = "Standard_D2s_v5"
}

variable "aks_network_plugin_mode" {
  description = "Optional Azure CNI mode. Use overlay only for a newly created cluster; changing an existing cluster requires replacement."
  type        = string
  default     = null

  validation {
    condition     = var.aks_network_plugin_mode == null || contains(["overlay"], var.aks_network_plugin_mode)
    error_message = "aks_network_plugin_mode must be null or overlay."
  }
}

variable "aks_pod_cidr" {
  description = "Optional Pod CIDR. Required by the Azure CNI Overlay capture profile and must not overlap the VNet or service CIDR."
  type        = string
  default     = null

  validation {
    condition     = var.aks_pod_cidr == null || can(cidrhost(var.aks_pod_cidr, 0))
    error_message = "aks_pod_cidr must be a valid CIDR when specified."
  }
}

variable "node_max_pods" {
  description = "Optional per-node pod cap. The overlay capture profile explicitly uses 250; leave null for the provider default."
  type        = number
  default     = null

  validation {
    condition     = var.node_max_pods == null || (var.node_max_pods >= 10 && var.node_max_pods <= 250)
    error_message = "node_max_pods must be between 10 and 250 when specified."
  }
}

variable "enable_managed_grafana" {
  description = "Create billable Azure Managed Grafana Standard X1 resources."
  type        = bool
  default     = false
}

variable "log_analytics_daily_quota_gb" {
  description = "Daily Log Analytics ingestion cap in GB. Keep -1 for the existing unlimited default; use a finite cap for short-lived capture environments."
  type        = number
  default     = -1

  validation {
    condition     = var.log_analytics_daily_quota_gb == -1 || var.log_analytics_daily_quota_gb > 0
    error_message = "log_analytics_daily_quota_gb must be -1 or a positive number."
  }
}

variable "application_insights_daily_data_cap_in_gb" {
  description = "Daily Application Insights cap in GB. The default preserves the existing deployment; temporary capture profiles should set a small finite cap."
  type        = number
  default     = 100

  validation {
    condition     = var.application_insights_daily_data_cap_in_gb > 0
    error_message = "application_insights_daily_data_cap_in_gb must be positive."
  }
}

variable "kubeconfig_path" {
  description = "Path to the dedicated kubeconfig used only for Terraform's OTel handoff objects."
  type        = string
}

variable "alert_email" {
  type        = string
  description = "Email address for AKS monitoring alerts"
}
