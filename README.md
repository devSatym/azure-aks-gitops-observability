# Azure AKS Container Platform

A modular Azure Kubernetes Service platform built with Terraform, Docker, Azure Container Registry, GitHub Actions, Kubernetes, and Azure-native monitoring. The platform is being extended with Helm, Prometheus, Grafana, and Argo CD to demonstrate application packaging, observability, and GitOps-based delivery.

The project demonstrates Infrastructure as Code, secure CI/CD authentication, automated workload deployment, monitoring, and operational alerting.

## Architecture

![Azure AKS Platform Architecture](docs/architecture/architecture-diagram.png)

```text
Developer
   │
   ▼
GitHub Repository
   │
   ▼
GitHub Actions
   │
   ├── Authenticate to Azure using OIDC
   ├── Build Docker image
   ├── Push image to ACR
   └── Deploy application to AKS
                         │
                         ▼
                LoadBalancer Service
                         │
                         ▼
                    Application
```

Monitoring flow:

```text
AKS
→ Container Insights
→ Log Analytics Workspace
→ Azure Monitor Alerts
→ Action Group
```

## Design Principles

The platform applies Azure architecture and Well-Architected principles through:

* **Infrastructure as Code:** Modular Terraform provides consistent and repeatable deployments.
* **Secure automation:** GitHub Actions uses OIDC instead of stored Azure credentials.
* **Operational excellence:** Automated deployment, rollout validation, centralised logging, and alerts improve operational visibility.
* **Reliability:** Kubernetes health checks and alerts help identify node and workload failures.
* **Observability:** Azure Monitor, Container Insights, and Log Analytics provide cluster and workload health data.
* **Cost awareness:** Lab resources can be destroyed when not required.

The design is informed by the Azure Well-Architected Framework, Azure Architecture Center AKS guidance, and Cloud Adoption Framework landing-zone principles.

## Technology Stack

| Area                   | Technology                                |
| ---------------------- | ----------------------------------------- |
| Cloud                  | Microsoft Azure                           |
| Infrastructure as Code | Terraform                                 |
| Containers             | Docker, AKS and ACR                       |
| CI/CD                  | GitHub Actions                            |
| Authentication         | OpenID Connect                            |
| Kubernetes             | Deployment, Pods and LoadBalancer Service |
| Monitoring             | Azure Monitor and Container Insights      |
| Logging                | Log Analytics Workspace                   |
| Alerting               | Azure Monitor Alerts and Action Groups    |

## Infrastructure

Terraform provisions the following resources:

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
5. Applies the Kubernetes manifest.
6. Validates the deployment rollout.

```text
.github/workflows/deploy-aks.yml
```

## Kubernetes Workload

The application is deployed using:

* Kubernetes Deployment
* Application Pods
* Azure LoadBalancer Service
* Container image stored in ACR
* Rollout validation through `kubectl`

## Monitoring and Alerting

Azure Monitor, Container Insights, and Log Analytics provide visibility into AKS cluster and workload health.

Configured alert scenarios include:

* Node unavailable or not ready
* Failed pods
* Pod restart increases
* Workload health degradation

Example Log Analytics query:

```kql
KubePodInventory
| where TimeGenerated > ago(1h)
| project TimeGenerated, Namespace, Name, PodStatus, ContainerStatus
| order by TimeGenerated desc
```

## Validation

```bash
kubectl get nodes
kubectl get deployments
kubectl get pods
kubectl get services
kubectl rollout status deployment/ram-webapp
```

Validate the container image:

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

### Application

![Application Running](docs/screenshots/07-browser-app-running.png)

### Monitoring

![Container Insights](docs/screenshots/08-container-insights.png)

### Alerts

![Alert Rules](docs/screenshots/10-alert-rules-action-group.png)

## Key Outcomes

* Provisioned Azure infrastructure using modular Terraform.
* Automated Docker image build and AKS deployment using GitHub Actions.
* Implemented secure Azure authentication using OIDC.
* Integrated ACR with the AKS application delivery workflow.
* Centralised Kubernetes logs and health data in Log Analytics.
* Configured proactive monitoring and operational alerts.

## Cleanup

To avoid unnecessary Azure charges:

```bash
terraform destroy
```

## Roadmap

* Terraform remote backend using Azure Storage
* Azure Key Vault integration
* Microsoft Entra Workload ID
* Private AKS and private ACR connectivity
* Azure Policy for AKS governance
* Helm-based application deployment
* Prometheus and Grafana dashboards
* Argo CD GitOps deployment
* Ingress controller and TLS
* Horizontal Pod Autoscaler
