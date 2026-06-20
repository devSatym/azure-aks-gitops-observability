Phase 4 — Helm Application Packaging
Objective

The objective of this phase was to replace raw Kubernetes manifest files with a reusable Helm chart.

Helm allows Kubernetes configuration to be templated, versioned and managed as an application release.

Why Helm Was Added

Raw Kubernetes YAML is suitable for initial learning and simple deployments, but repeated environments can result in duplicated configuration.

Helm provides:

Reusable Kubernetes templates
Centralised configuration through values.yaml
Release tracking
Upgrade support
Rollback support
Environment-specific values
Reduced YAML duplication
Helm Chart Structure
helm/
└── ram-webapp/
    ├── Chart.yaml
    ├── values.yaml
    └── templates/
        ├── deployment.yaml
        └── service.yaml
Chart Components
Chart.yaml

Contains chart metadata:

Chart name
Chart version
Application version
Description
values.yaml

Contains configurable application values:

Image repository
Image tag
Replica count
Container port
Service type
Service port
deployment.yaml

Creates the Kubernetes Deployment and application Pods.

service.yaml

Creates the Kubernetes Service that exposes the application.

Manual Helm Deployment

Install or upgrade the application:

helm upgrade --install ram-webapp ./helm/ram-webapp \
  --set image.repository=<acr-login-server>/ram-aks-web \
  --set image.tag=<image-tag>
Helm Validation

List Helm releases:

helm list

Check release status:

helm status ram-webapp

Check release history:

helm history ram-webapp

Render the templates without deploying:

helm template ram-webapp ./helm/ram-webapp

Validate the chart:

helm lint ./helm/ram-webapp
Upgrade

Deploy a new application image:

helm upgrade ram-webapp ./helm/ram-webapp \
  --set image.repository=<acr-login-server>/ram-aks-web \
  --set image.tag=<new-image-tag>
Rollback

View release history:

helm history ram-webapp

Rollback to a previous release:

helm rollback ram-webapp <revision-number>
Outcome

This phase converted the application deployment into a reusable and manageable Helm release that could later be controlled through Argo CD.