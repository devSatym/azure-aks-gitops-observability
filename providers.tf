terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38"
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

# Terraform owns only the native-OTLP handoff objects in the cluster: the
# namespace, collector service account, and non-secret endpoint ConfigMap.
# The live cluster disables local admin accounts, so use the explicitly supplied
# project kubeconfig rather than a default context or an unavailable admin one.
provider "kubernetes" {
  config_path = var.kubeconfig_path
}
