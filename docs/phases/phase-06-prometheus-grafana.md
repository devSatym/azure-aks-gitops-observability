Phase 6 — Prometheus and Grafana
Objective

The objective of this phase was to add Kubernetes-native metrics collection and dashboard visualisation.

Prometheus collects Kubernetes metrics, while Grafana presents those metrics through operational dashboards.

Monitoring Stack

Prometheus and Grafana were installed using the kube-prometheus-stack Helm chart.

The stack commonly includes:

Prometheus
Grafana
Alertmanager
Node Exporter
kube-state-metrics
Prometheus Operator
Kubernetes monitoring rules
Installation

Add the Prometheus community Helm repository:

helm repo add prometheus-community \
  https://prometheus-community.github.io/helm-charts

Update the repository:

helm repo update

Install the monitoring stack:

helm upgrade --install kube-prometheus-stack \
  prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace
Monitoring Flow
AKS Nodes and Workloads
   ↓
Prometheus Exporters
   ↓
Prometheus Metrics Collection
   ↓
Grafana Data Source
   ↓
Kubernetes Dashboards
Metrics Visibility

The monitoring stack provides visibility into:

Cluster health
Node CPU and memory usage
Namespace resource usage
Pod CPU and memory usage
Pod restart counts
Kubernetes Deployment status
StatefulSet and DaemonSet status
API server and scheduler metrics
Validation

Check monitoring Pods:

kubectl get pods -n monitoring

Check the Helm release:

helm list -n monitoring

Check release status:

helm status kube-prometheus-stack -n monitoring
Access Grafana

Forward the local port:

kubectl port-forward \
  svc/kube-prometheus-stack-grafana \
  3000:80 \
  -n monitoring

Open:

http://localhost:3000
Validated Dashboard
Kubernetes / Compute Resources / Cluster

This dashboard provides a high-level view of:

Cluster CPU usage
Cluster memory usage
Namespace resource consumption
Pod resource consumption
Evidence




Outcome

This phase added detailed Kubernetes metrics and dashboard-based observability alongside Azure-native monitoring.