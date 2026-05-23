# Azure AKS Container Platform

A modular Azure Kubernetes Service platform built with Terraform, Docker, Azure Container Registry, GitHub Actions, Helm, Argo CD, Azure Monitor, Prometheus, and Grafana.

This project demonstrates secure infrastructure provisioning, container image delivery, GitOps deployment, Kubernetes monitoring, and operational alerting.

## Architecture

![Azure AKS Platform Architecture](docs/architecture/architecture-diagram.png)

```text
Developer
   ↓
GitHub Repository
   ↓
GitHub Actions
   ↓
Docker Build → Azure Container Registry
   ↓
Argo CD watches Helm chart
   ↓
AKS Deployment
   ↓
LoadBalancer Service
   ↓
Application
```

Monitoring:

```text
AKS
├── Container Insights → Log Analytics → Azure Monitor Alerts
└── Prometheus → Grafana Dashboards
```

## Key Features

* Modular Azure infrastructure using Terraform
* Secure GitHub Actions authentication using OIDC
* Docker image build and push to Azure Container Registry
* Helm-based Kubernetes application packaging
* Argo CD GitOps deployment and drift reconciliation
* Azure Monitor, Container Insights, and Log Analytics
* AKS alert rules with Action Group notifications
* Prometheus and Grafana Kubernetes observability
* Clear separation between CI and GitOps responsibilities

## Technology Stack

| Area                     | Technology                         |
| ------------------------ | ---------------------------------- |
| Cloud                    | Microsoft Azure                    |
| Infrastructure as Code   | Terraform                          |
| Container Platform       | Azure Kubernetes Service           |
| Container Registry       | Azure Container Registry           |
| Containerisation         | Docker                             |
| Continuous Integration   | GitHub Actions                     |
| Authentication           | OpenID Connect                     |
| Application Packaging    | Helm                               |
| GitOps                   | Argo CD                            |
| Azure Monitoring         | Azure Monitor, Container Insights  |
| Logging                  | Log Analytics                      |
| Alerting                 | Azure Monitor Alerts, Action Group |
| Kubernetes Observability | Prometheus, Grafana                |

## Infrastructure

Terraform provisions:

```text
Resource Group
Virtual Network and Subnet
Azure Container Registry
Azure Kubernetes Service
Log Analytics Workspace
Container Insights
Azure Monitor Alerts
Action Group
```

Module structure:

```text
modules/
├── resource_group/
├── network/
├── acr/
├── aks/
├── monitoring/
└── alerts/
```

## Delivery Workflow

The platform separates image creation from Kubernetes deployment.

### GitHub Actions

GitHub Actions:

1. Authenticates to Azure using OIDC.
2. Builds the Docker image.
3. Pushes the image to Azure Container Registry.

Workflow:

```text
.github/workflows/deploy-aks.yml
```

```text
Git Push
   ↓
GitHub Actions
   ↓
Docker Build
   ↓
Push Image to ACR
```

### Argo CD

Argo CD:

1. Watches the GitHub repository.
2. Reads the Helm chart from `helm/ram-webapp`.
3. Deploys the desired configuration to AKS.
4. Detects and corrects configuration drift.

```text
GitHub Repository
   ↓
Argo CD
   ↓
Helm Chart
   ↓
AKS
```

Expected application state:

```text
Sync Status: Synced
Health Status: Healthy
```

## Helm Deployment

The application was migrated from raw Kubernetes manifests to Helm.

Helm chart structure:

```text
helm/
└── ram-webapp/
    ├── Chart.yaml
    ├── values.yaml
    └── templates/
        ├── deployment.yaml
        └── service.yaml
```

Manual Helm deployment:

```bash
helm upgrade --install ram-webapp ./helm/ram-webapp \
  --set image.repository=<acr-login-server>/ram-aks-web \
  --set image.tag=<image-tag>
```

Helm provides reusable templates, centralised configuration, release history, upgrades, and rollback support.

## Kubernetes Workload

The application runs on AKS using:

* Kubernetes Deployment
* Application Pods
* LoadBalancer Service
* Container image stored in ACR
* Helm release configuration
* Argo CD automated synchronisation

## Monitoring and Alerting

Azure Monitor, Container Insights, and Log Analytics provide visibility into cluster and workload health.

Configured alert scenarios include:

* Node not ready
* Failed pods
* Pod restarts
* Workload health degradation

Example KQL query:

```kql
KubePodInventory
| where TimeGenerated > ago(1h)
| project TimeGenerated, Namespace, Name, PodStatus, ContainerStatus
| order by TimeGenerated desc
```

## Prometheus and Grafana

Prometheus and Grafana were installed using the `kube-prometheus-stack` Helm chart.

```bash
helm upgrade --install kube-prometheus-stack \
  prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace
```

The stack provides visibility into:

* Cluster health
* Node resource usage
* Namespace resource usage
* Pod CPU and memory usage
* Kubernetes workload status

Access Grafana locally:

```bash
kubectl port-forward \
  svc/kube-prometheus-stack-grafana \
  3000:80 \
  -n monitoring
```

Validated dashboard:

```text
Kubernetes / Compute Resources / Cluster
```

## Validation

### Kubernetes

```bash
kubectl get nodes
kubectl get deployments
kubectl get pods
kubectl get svc
kubectl rollout status deployment/ram-webapp
```

### Helm

```bash
helm list
helm status ram-webapp
```

### Argo CD

```bash
kubectl get pods -n argocd
kubectl get applications -n argocd
kubectl get application ram-webapp -n argocd
```

### Monitoring

```bash
kubectl get pods -n monitoring
helm list -n monitoring
```

### Azure Container Registry

```bash
az acr repository show-tags \
  --name <acr-name> \
  --repository ram-aks-web \
  --output table
```

## Project Evidence

### GitHub Actions

![GitHub Actions Success](docs/screenshots/02-github-actions-success.png)

### Azure Infrastructure

![Azure Resource Group](docs/screenshots/03-azure-resource-group.png)

### Kubernetes Workload

![Kubernetes Pods and Service](docs/screenshots/06-kubectl-pods-service.png)

### Application

![Application Running](docs/screenshots/07-browser-app-running.png)

### Azure Monitoring and Alerts

![Alert Rules](docs/screenshots/10-alert-rules-action-group.png)

### Grafana Dashboard

![Grafana Kubernetes Dashboard](docs/screenshots/16-grafana-kubernetes-cluster-dashboard.png)

### Argo CD Application

![Argo CD Synced and Healthy](docs/screenshots/17-argocd-application-synced-healthy.png)

### GitOps Reconciliation

![Argo CD Reconciliation](docs/screenshots/21-argocd-replica-reconciliation.png)

## Key Outcomes

* Provisioned repeatable Azure infrastructure using modular Terraform.
* Implemented passwordless GitHub Actions authentication using OIDC.
* Automated Docker image build and delivery to ACR.
* Migrated application deployment from raw YAML to Helm.
* Implemented Argo CD as the Kubernetes deployment owner.
* Separated continuous integration from GitOps delivery.
* Validated automatic synchronisation and drift reconciliation.
* Enabled AKS monitoring with Container Insights and Log Analytics.
* Added proactive Azure Monitor alerting.
* Deployed Prometheus and Grafana for Kubernetes-native observability.

## Cleanup

Remove Prometheus and Grafana:

```bash
helm uninstall kube-prometheus-stack -n monitoring
kubectl delete namespace monitoring
```

Remove Argo CD:

```bash
kubectl delete namespace argocd
```

Destroy Azure infrastructure:

```bash
terraform destroy
```

## Future Improvements

* Terraform remote backend using Azure Storage
* Azure Key Vault integration
* Microsoft Entra Workload Identity
* Private AKS and ACR connectivity
* Azure Policy for AKS governance
* Ingress controller with TLS
* Horizontal Pod Autoscaler
