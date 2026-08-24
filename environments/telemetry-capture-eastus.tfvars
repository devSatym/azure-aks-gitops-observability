# Temporary, isolated telemetry-capture profile.
#
# Use only in the telemetry-capture-eastus Terraform workspace. It deliberately
# overrides the ignored Central India terraform.tfvars values, but inherits the
# locally supplied alert_email. The kubeconfig path is dedicated to this cluster.
location     = "eastus"
project_name = "aksops"
environment  = "capture"

# This subscription's East US AKS policy permits Dsv7 rather than Dsv5 sizes,
# and its Dsv7 / regional quota has exactly four unused vCPUs. The temporary
# cluster therefore uses two D2s_v7 nodes. Do not increase this without a new
# quota check and a reviewed cost estimate.
node_count   = 2
node_vm_size = "Standard_D2s_v7"

# Azure CNI Overlay prevents the legacy Azure CNI 30-pod-per-node ceiling from
# blocking the 22-service demo. The explicit 250 cap is a pod-address capacity
# setting, not an authorization to add application replicas.
aks_network_plugin_mode = "overlay"
aks_pod_cidr            = "10.244.0.0/16"
node_max_pods           = 250

# Keep the optional billable managed Grafana resource disabled.
enable_managed_grafana = false

# Cap the two telemetry data paths at 5 GB/day. The expected 2–3 hour capture
# is well below this; the cap is an additional guardrail, not a hard billing
# guarantee because Azure ingestion and cost reporting can lag.
log_analytics_daily_quota_gb              = 5
application_insights_daily_data_cap_in_gb = 5

# Terraform must never use the Central India kubeconfig when applying its
# in-cluster OTel handoff objects for this temporary environment.
kubeconfig_path = "/tmp/azure-aks-telemetry-capture-eastus.kubeconfig"
