variable "namespace" {
  type = string
}

variable "collector_service_account_name" {
  type = string
}

variable "collector_client_id" {
  type = string
}

variable "endpoint_config_map_name" {
  type = string
}

variable "traces_endpoint" {
  type = string
}

variable "logs_endpoint" {
  type = string
}

variable "metrics_endpoint" {
  type = string
}
