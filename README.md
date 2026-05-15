# Azure AKS Container Platform

## Project Overview

This project demonstrates an enterprise-style Azure Kubernetes platform built using Terraform, Azure Kubernetes Service (AKS), Azure Container Registry (ACR), GitHub Actions, Helm, Azure Monitor, Log Analytics, and Azure Monitor Alerts.

The solution focuses on secure Infrastructure as Code, automated application delivery, Kubernetes workload management, and operational monitoring following Azure cloud engineering practices.

---

## Architecture

![Azure AKS Platform Architecture](docs/architecture/architecture-diagram.png)

---

## Solution Flow

```text
Developer
    │
    ▼
GitHub Repository
    │
    ▼
GitHub Actions
    │
    ├── Azure Login (OIDC)
    ├── Build Docker Image
    ├── Push Image to ACR
    ├── Deploy using Helm
    └── Validate Rollout
                    │
                    ▼
             Azure Kubernetes Service
                    │
          LoadBalancer Service
                    │
                    ▼
             Application Pods
```

Monitoring

```text
AKS
→ Container Insights
→ Log Analytics Workspace
→ Azure Monitor Alerts
→ Action Group
```

---

# Key Features

- Modular Terraform Infrastructure as Code
- Secure GitHub Actions authentication using OIDC
- Docker image build and Azure Container Registry integration
- Helm-based Kubernetes application deployment
- Azure Monitor, Container Insights and Log Analytics
- Azure Monitor Alerts with Action Groups
- Repeatable deployment and rollout validation

---

# Technology Stack

| Area | Technology |
|------|------------|
| Cloud | Microsoft Azure |
| Infrastructure | Terraform |
| Containers | Docker |
| Kubernetes | Azure Kubernetes Service |
| Registry | Azure Container Registry |
| CI/CD | GitHub Actions |
| Authentication | OpenID Connect |
| Application Packaging | Helm |
| Monitoring | Azure Monitor |
| Logging | Log Analytics Workspace |
| Alerting | Azure Monitor Alerts |

---

# Infrastructure Provisioned

Terraform deploys:

```text
Resource Group
Virtual Network
Azure Container Registry
Azure Kubernetes Service
Log Analytics Workspace
Container Insights
Alert Rules
Action Group
```

Terraform modules

```text
modules/
├── resource_group/
├── network/
├── acr/
├── aks/
├── monitoring/
└── alerts/
```

---

# CI/CD Pipeline

The GitHub Actions workflow performs:

1. Azure authentication using OIDC
2. Docker image build
3. Push image to Azure Container Registry
4. Retrieve AKS credentials
5. Helm deployment
6. Rollout validation

Workflow

```text
.github/workflows/deploy-aks.yml
```

Pipeline flow

```text
Git Push
      │
      ▼
GitHub Actions
      │
Docker Build
      │
Push to ACR
      │
Helm Upgrade / Install
      │
AKS Deployment
      │
Rollout Validation
```

---

# Helm Deployment

The application deployment has been upgraded from raw Kubernetes manifests to Helm.

Previous deployment

```bash
kubectl apply -f k8s/ram-webapp.yaml
```

Current deployment

```bash
helm upgrade --install ram-webapp ./helm/ram-webapp \
  --set image.repository=<acr-login-server>/ram-aks-web \
  --set image.tag=<image-tag>
```

Helm chart structure

```text
helm/
└── ram-webapp/
    ├── Chart.yaml
    ├── values.yaml
    └── templates/
        ├── deployment.yaml
        └── service.yaml
```

Benefits

- Reusable templates
- Centralised configuration
- Easier upgrades
- Easier rollbacks
- Versioned releases

---

# Monitoring & Alerts

Azure Monitor collects AKS telemetry through Container Insights.

Monitoring includes:

- Node health
- Pod health
- Container logs
- Deployment health

Alert scenarios:

- Node Not Ready
- Failed Pods
- Pod Restarts
- Workload degradation

---

# Validation

```bash
kubectl get nodes
kubectl get deployments
kubectl get pods
kubectl get svc

helm list
helm status ram-webapp
```

---

# Project Evidence

### Architecture

![Architecture](docs/architecture/architecture-diagram.png)

### GitHub Actions

![GitHub Actions](docs/screenshots/02-github-actions-success.png)

### Azure Resources

![Azure Resources](docs/screenshots/03-azure-resource-group.png)

### Kubernetes Workload

![Pods](docs/screenshots/06-kubectl-pods-service.png)

### Application

![Application](docs/screenshots/07-browser-app-running.png)

### Monitoring

![Monitoring](docs/screenshots/08-container-insights.png)

### Alerts

![Alerts](docs/screenshots/10-alert-rules-action-group.png)

### Helm Chart

![Helm Structure](docs/screenshots/11-helm-folder-structure.png)

### Helm Deployment

![Helm Deployment](docs/screenshots/12-github-actions-helm-success.png)

### Helm Release

![Helm Release](docs/screenshots/13-helm-release-kubectl-output.png)

---

# Key Outcomes

- Designed modular Azure infrastructure using Terraform.
- Implemented secure CI/CD using GitHub Actions and OIDC.
- Automated Docker image delivery to Azure Container Registry.
- Migrated Kubernetes deployment from raw YAML to Helm.
- Implemented Azure-native monitoring and alerting.
- Validated application rollout and Kubernetes workload health.

---

# Cleanup

```bash
terraform destroy
```

---

# Next Enhancements

- Terraform Remote Backend
- Azure Key Vault
- Microsoft Entra Workload Identity
- Prometheus
- Grafana
- Argo CD
- Ingress Controller
- Horizontal Pod Autoscaler

---

# Project Evolution

```text
Version 1
Terraform
AKS
GitHub Actions
Azure Monitor
Alerts

        │

Version 2
Helm Deployment ✅

        │

Next
Prometheus + Grafana

        │

Future
Argo CD GitOps
```