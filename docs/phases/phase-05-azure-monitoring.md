# Phase 5 — Azure Monitoring and Alerting

> Historical phase note: this document describes the monitoring design. Read `docs/codex/03-VALIDATION.md` for current ingestion and alert-test evidence; do not infer that an alert or email was verified solely from the configuration described here.

Objective

The objective of this phase was to provide Azure-native visibility into AKS cluster and workload health.

Azure Monitor, Container Insights and Log Analytics were used to collect and analyse operational data.

Monitoring Architecture
Azure Kubernetes Service
   ↓
Container Insights
   ↓
Log Analytics Workspace
   ↓
KQL Queries
   ↓
Azure Monitor Alert Rules
   ↓
Action Group Notifications
Container Insights

Container Insights provides visibility into:

AKS cluster health
Node health
Pod status
Container status
CPU usage
Memory usage
Pod restart behaviour
Kubernetes inventory
Log Analytics

AKS telemetry is stored in a Log Analytics Workspace.

This allows platform and workload information to be queried using Kusto Query Language.

Example KQL Query
KubePodInventory
| where TimeGenerated > ago(1h)
| project TimeGenerated, Namespace, Name, PodStatus, ContainerStatus
| order by TimeGenerated desc

This query displays recent Pod and container status information.

Alert Scenarios

Terraform configures the following alert scenarios; their individual validation status belongs in the current validation record:

Node not ready
Failed Pods
Pod restarts
Workload health degradation
Unexpected container termination
Action Group

The Azure Monitor Action Group defines the notification destination for an alert.

The alert flow is:

AKS Condition Detected
   ↓
Azure Monitor Alert Rule
   ↓
Alert Fired
   ↓
Action Group
   ↓
Email or Notification
Monitoring Validation

Validate that Container Insights is connected:

az aks show \
  --resource-group <resource-group-name> \
  --name <aks-cluster-name> \
  --query addonProfiles.omsagent

For managed-identity Container Insights onboarding, also verify that the data collection rule and its association with AKS exist, then validate actual Log Analytics ingestion with KQL.

Check recent Pods:

kubectl --kubeconfig <project-kubeconfig> get pods --all-namespaces

Check Pod restart counts:

kubectl --kubeconfig <project-kubeconfig> get pods \
  --all-namespaces \
  -o custom-columns="NAMESPACE:.metadata.namespace,POD:.metadata.name,RESTARTS:.status.containerStatuses[*].restartCount"
Evidence




Outcome

This phase records the Azure-native monitoring design. Only captured validation evidence establishes that ingestion or notification delivery is working in a live environment.
