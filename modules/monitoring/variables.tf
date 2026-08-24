variable "name_prefix" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "daily_quota_gb" {
  type = number
}

variable "tags" {
  type = map(string)
}
