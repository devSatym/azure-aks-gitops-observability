# Phase 1 — Azure Infrastructure Foundation

> Historical phase note: this is a design record, not the current operating runbook or evidence record. Use the current status and validation records under `docs/codex/` before making infrastructure changes.

Objective

The objective of this phase was to provision a repeatable Azure infrastructure foundation for running containerised applications on Azure Kubernetes Service.

Terraform was used to improve consistency, reduce manual configuration and support repeatable platform deployment.

Resources Provisioned

Terraform provisions the following Azure resources:

Resource Group
Virtual Network
AKS Subnet
Azure Container Registry
Azure Kubernetes Service
Log Analytics Workspace
Container Insights
Azure Monitor Alert Rules
Action Group
Terraform Modules

The Terraform configuration is separated into reusable modules:

modules/
├── resource_group/
├── network/
├── acr/
├── aks/
├── monitoring/
├── container_insights/
└── alerts/
Module	Responsibility
resource_group	Creates the Azure resource group
network	Creates the virtual network and AKS subnet
acr	Creates Azure Container Registry
aks	Creates the AKS cluster and node pool
monitoring	Creates the Log Analytics workspace
container_insights	Creates the Container Insights data collection rule and AKS association
alerts	Creates alert rules and the notification Action Group
Infrastructure Dependency Flow
Resource Group
   ↓
Virtual Network and AKS Subnet
   ↓
Azure Container Registry
   ↓
Azure Kubernetes Service
   ↓
Log Analytics and Container Insights
   ↓
Alert Rules and Action Group
Terraform Deployment Workflow
Terraform Configuration
   ↓
terraform init
   ↓
terraform fmt
   ↓
terraform validate
   ↓
terraform plan
   ↓
terraform apply
   ↓
Azure Resources
Terraform Commands
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
AKS Connection

Retrieve the AKS credentials:

az aks get-credentials \
  --resource-group <resource-group-name> \
  --name <aks-cluster-name> \
  --file <project-kubeconfig> \
  --overwrite-existing

Validate the cluster nodes:

kubectl --kubeconfig <project-kubeconfig> get nodes

Expected result:

STATUS: Ready
Infrastructure Validation

List resources in the resource group:

az resource list \
  --resource-group <resource-group-name> \
  --output table

Validate the AKS cluster:

az aks show \
  --resource-group <resource-group-name> \
  --name <aks-cluster-name> \
  --output table

Validate Azure Container Registry:

az acr show \
  --name <acr-name> \
  --output table
Evidence




Outcome

This phase describes the infrastructure foundation for application delivery, CI, monitoring, and GitOps. Confirm the currently provisioned state through the validation records before relying on it.
