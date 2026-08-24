variable "name_prefix" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "aks_name" {
  type = string
}

variable "aks_id" {
  type = string
}

variable "tags" {
  type = map(string)
}
