# Phase 6 — Prometheus and Grafana

> Historical phase note: this guide describes the monitoring-stack installation pattern. Use a dedicated project kubeconfig for every Helm or `kubectl` command, and consult `docs/codex/03-validation.md` for live evidence.

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
  --create-namespace \
  --kubeconfig <project-kubeconfig>
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

kubectl --kubeconfig <project-kubeconfig> get pods -n monitoring

Check the Helm release:

helm list -n monitoring --kubeconfig <project-kubeconfig>

Check release status:

helm status kube-prometheus-stack -n monitoring --kubeconfig <project-kubeconfig>
Access Grafana

Forward the local port:

kubectl --kubeconfig <project-kubeconfig> port-forward \
  svc/kube-prometheus-stack-grafana \
  3000:80 \
  -n monitoring

Open:

http://localhost:3000
Dashboard to Inspect
Kubernetes / Compute Resources / Cluster

This dashboard provides a high-level view of:

Cluster CPU usage
Cluster memory usage
Namespace resource consumption
Pod resource consumption
Evidence




Outcome

This phase describes the intended in-cluster metrics and dashboard capability. Confirm installed components, scrape health, and dashboard access through current validation evidence.
