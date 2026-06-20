Phase 7 — Argo CD GitOps
Objective

The objective of this phase was to implement GitOps-based Kubernetes deployment using Argo CD.

Git became the source of truth for the desired application configuration.

Why GitOps Was Added

Before GitOps, a deployment pipeline or engineer can directly run deployment commands against Kubernetes.

GitOps improves this model by providing:

Git as the desired-state source
Automated synchronisation
Deployment history
Configuration drift detection
Self-healing
Clear separation between CI and deployment
Improved auditability
CI and GitOps Separation
GitHub Actions responsibility
Application Source Change
   ↓
Build Docker Image
   ↓
Push Image to ACR
Argo CD responsibility
Helm Configuration Change
   ↓
Read Desired State from Git
   ↓
Compare Git with AKS
   ↓
Synchronise Application
   ↓
Correct Configuration Drift

GitHub Actions builds the application artifact.

Argo CD deploys and reconciles the Kubernetes configuration.

GitOps Architecture
GitHub Repository
   ↓
Helm Chart
   ↓
Argo CD
   ↓
Desired-State Comparison
   ↓
Azure Kubernetes Service
Argo CD Responsibilities

Argo CD:

Watches the GitHub repository.
Reads the Helm chart from helm/ram-webapp.
Renders the Helm templates.
Compares the desired state with AKS.
Applies required changes.
Detects configuration drift.
Reconciles the application automatically.
Expected Application State
Sync Status: Synced
Health Status: Healthy
Synced

The resources deployed in AKS match the desired configuration stored in Git.

Healthy

The Kubernetes resources are running successfully.

Automated Synchronisation

Automated synchronisation allows Argo CD to apply changes when Git is updated.

Self-healing allows Argo CD to correct manual changes made directly in the cluster.

Pruning allows Argo CD to remove Kubernetes resources that were deleted from Git.

Validation

Check Argo CD Pods:

kubectl get pods -n argocd

List Argo CD applications:

kubectl get applications -n argocd

Inspect the application:

kubectl get application ram-webapp -n argocd

Describe the application:

kubectl describe application ram-webapp -n argocd

Validate the application Deployment:

kubectl get deployment ram-webapp

Validate the application Pods:

kubectl get pods
Drift Reconciliation Test

A simple reconciliation test can be performed by manually changing the Deployment replica count:

kubectl scale deployment ram-webapp --replicas=3

When self-healing is enabled, Argo CD should return the Deployment to the replica count defined in Git.

Validate:

kubectl get deployment ram-webapp
Evidence







Outcome

This phase implemented Git-driven Kubernetes deployment, automated synchronisation and configuration drift reconciliation.