# Azure AKS Container Platform

A modular Azure Kubernetes Service platform built with Terraform, Docker, Azure Container Registry, GitHub Actions, Helm, Kubernetes, and Azure-native monitoring.

The project demonstrates Infrastructure as Code, secure CI/CD authentication, container image delivery, Helm-based application deployment, AKS monitoring, and operational alerting.

## Architecture

![Azure AKS Platform Architecture](docs/architecture/architecture-diagram.png)

```text
Developer
→ GitHub Repository
→ GitHub Actions
→ Docker Build
→ Azure Container Registry
→ AKS
→ Kubernetes Service LoadBalancer
→ Application
```

Monitoring flow:

```text
AKS
→ Container Insights
→ Log Analytics Workspace
→ Azure Monitor Alerts
→ Action Group
```

## Key Features

- Modular Terraform infrastructure
- Secure GitHub Actions authentication using OIDC
- Docker image build and push to Azure Container Registry
- Helm-based AKS application deployment
- Azure Monitor, Container Insights, and Log Analytics
- Azure Monitor alert rules and Action Group notifications
- Kubernetes rollout validation

## Technology Stack

| Area | Technology |
|---|---|
| Cloud | Microsoft Azure |
| Infrastructure as Code | Terraform |
| Container Platform | AKS |
| Container Registry | ACR |
| Containerisation | Docker |
| CI/CD | GitHub Actions |
| Authentication | OIDC |
| Application Packaging | Helm |
| Monitoring | Azure Monitor, Container Insights |
| Logging | Log Analytics Workspace |
| Alerting | Azure Monitor Alerts, Action Group |

## Infrastructure Provisioned

Terraform provisions:

```text
Resource Group
Virtual Network and Subnet
Azure Container Registry
Azure Kubernetes Service
Log Analytics Workspace
Container Insights
Alert Rules
Action Group
```

Terraform module structure:

```text
modules/
├── resource_group/
├── network/
├── acr/
├── aks/
├── monitoring/
└── alerts/
```

## CI/CD Pipeline

The GitHub Actions workflow:

1. Authenticates to Azure using OIDC.
2. Builds the Docker image.
3. Pushes the image to Azure Container Registry.
4. Retrieves AKS credentials.
5. Deploys the application using Helm.
6. Validates the rollout.

Workflow file:

```text
.github/workflows/deploy-aks.yml
```

## Helm Deployment

The application deployment was upgraded from raw Kubernetes manifests to Helm.

Previous deployment method:

```bash
kubectl apply -f k8s/ram-webapp.yaml
```

Current deployment method:

```bash
helm upgrade --install ram-webapp ./helm/ram-webapp \
  --set image.repository=<acr-login-server>/ram-aks-web \
  --set image.tag=<image-tag>
```

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

Helm provides reusable templates, centralised configuration, release tracking, and easier upgrades or rollbacks.

## Kubernetes Workload

The application runs on AKS using:

- Helm chart
- Kubernetes Deployment
- Application Pods
- Kubernetes Service type `LoadBalancer`
- Container image stored in ACR

## Monitoring and Alerting

Azure Monitor, Container Insights, and Log Analytics provide visibility into AKS cluster and workload health.

Configured alert scenarios:

- Node Not Ready
- Failed Pods
- Pod Restarts
- Workload health degradation

Example KQL query:

```kql
KubePodInventory
| where TimeGenerated > ago(1h)
| project TimeGenerated, Namespace, Name, PodStatus, ContainerStatus
| order by TimeGenerated desc
```

## Validation Commands

Validate Kubernetes resources:

```bash
kubectl get nodes
kubectl get deployments
kubectl get pods
kubectl get svc
kubectl rollout status deployment/ram-webapp
```

Validate Helm release:

```bash
helm list
helm status ram-webapp
```

Validate ACR image tags:

```bash
az acr repository show-tags \
  --name <acr-name> \
  --repository ram-aks-web \
  --output table
```

## Project Evidence

### GitHub Actions Deployment

![GitHub Actions Success](docs/screenshots/02-github-actions-success.png)

### Azure Resources

![Azure Resource Group](docs/screenshots/03-azure-resource-group.png)

### Kubernetes Workload

![Kubernetes Pods and Service](docs/screenshots/06-kubectl-pods-service.png)

### Application Running

![Application Running](docs/screenshots/07-browser-app-running.png)

### Monitoring

![Container Insights](docs/screenshots/08-container-insights.png)

### Alerts

![Alert Rules](docs/screenshots/10-alert-rules-action-group.png)

### Helm Chart Structure

![Helm Chart Structure](docs/screenshots/11-helm-folder-structure.png)

### Helm Deployment

![GitHub Actions Helm Success](docs/screenshots/12-github-actions-helm-success.png)

### Helm Release

![Helm Release and AKS Workloads](docs/screenshots/13-helm-release-kubectl-output.png)

## Key Outcomes

- Provisioned Azure infrastructure using modular Terraform.
- Automated Docker image build and AKS deployment using GitHub Actions.
- Implemented secure Azure authentication using OIDC.
- Integrated ACR with AKS application delivery.
- Upgraded deployment from raw Kubernetes YAML to Helm.
- Enabled AKS monitoring using Container Insights and Log Analytics.
- Configured proactive alerting for AKS workload health.

## Cleanup

To avoid unnecessary Azure charges:

```bash
terraform destroy
```

## Roadmap

- Terraform remote backend using Azure Storage
- Azure Key Vault integration
- Microsoft Entra Workload ID
- Private AKS and private ACR connectivity
- Azure Policy for AKS governance
- Prometheus and Grafana dashboards
- Argo CD GitOps deployment
- Ingress controller and TLS
- Horizontal Pod Autoscaler

## Project Versions

```text
Version 1: AKS + Terraform + GitHub Actions + Azure Monitor + Alerts
Version 2: Helm-based AKS application deployment
Next: Prometheus + Grafana
Future: Argo CD GitOps
```