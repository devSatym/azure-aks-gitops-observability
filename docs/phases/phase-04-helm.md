# Phase 4 — Helm Application Packaging

> Historical phase note: `helm/azure-webapp` is current desired-state source material, but Argo CD owns its reconciliation in AKS. Do not create, upgrade, roll back, or uninstall an `azure-webapp` Helm release directly.

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
└── azure-webapp/
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

Supported Chart Checks

Render the templates without deploying:

helm template azure-webapp ./helm/azure-webapp

Validate the chart:

helm lint ./helm/azure-webapp
Application image changes are made by committing the intended immutable tag to `values.yaml`; Argo CD then detects and reconciles the Git revision. Inspect the Argo CD `Application` for release state rather than Helm release history.

Outcome

This phase established a reusable Helm chart. It is a GitOps input, not a directly operated application release.
