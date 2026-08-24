# Temporary, isolated telemetry-capture profile.
#
# Use only in the telemetry-capture-eastus Terraform workspace. It deliberately
# overrides the ignored Central India terraform.tfvars values, but inherits the
# locally supplied alert_email. The kubeconfig path is dedicated to this cluster.
location     = "eastus"
project_name = "aksops"
environment  = "capture"

# East US currently has exactly four unused DSv5 / regional vCPUs, so this
# temporary cluster uses two D2s_v5 nodes. Do not increase this without a new
# quota check and a reviewed cost estimate.
node_count   = 2
node_vm_size = "Standard_D2s_v5"

# Azure CNI Overlay prevents the legacy Azure CNI 30-pod-per-node ceiling from
# blocking the 22-service demo. The explicit 250 cap is a pod-address capacity
# setting, not an authorization to add application replicas.
aks_network_plugin_mode = "overlay"
aks_pod_cidr            = "10.244.0.0/16"
node_max_pods           = 250

# Keep the optional billable managed Grafana resource disabled.
enable_managed_grafana = false

# Terraform must never use the Central India kubeconfig when applying its
# in-cluster OTel handoff objects for this temporary environment.
kubeconfig_path = "/tmp/azure-aks-telemetry-capture-eastus.kubeconfig"
