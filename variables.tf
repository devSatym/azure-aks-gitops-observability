variable "location" {
  description = "Azure region"
  type        = string
  default     = "australiaeast"
}

variable "project_name" {
  description = "Project short name"
  type        = string
  default     = "aksdemo"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "node_count" {
  description = "AKS node count"
  type        = number
  default     = 1
}

variable "node_vm_size" {
  description = "AKS node VM size"
  type        = string
  default     = "Standard_B2s"
}

variable "alert_email" {
  type        = string
  description = "Email address for AKS monitoring alerts"
}