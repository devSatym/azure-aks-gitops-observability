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
  description = "AKS node count"
  type        = number
  default     = 3
}

variable "node_vm_size" {
  description = "AKS node VM size"
  type        = string
  default     = "Standard_D2s_v5"
}

variable "enable_managed_grafana" {
  description = "Create billable Azure Managed Grafana Standard X1 resources."
  type        = bool
  default     = false
}

variable "kubeconfig_path" {
  description = "Path to the dedicated kubeconfig used only for Terraform's OTel handoff objects."
  type        = string
}

variable "alert_email" {
  type        = string
  description = "Email address for AKS monitoring alerts"
}
