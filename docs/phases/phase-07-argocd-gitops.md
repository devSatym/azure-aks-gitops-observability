# Phase 7 — Argo CD GitOps

> Historical phase note: this is the supported application ownership model. Make application changes in Git; do not use direct Helm or raw-manifest deployment commands. Refer to `docs/codex/03-VALIDATION.md` for the observed application status and drift-test evidence.

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
Reads the Helm chart from helm/azure-webapp.
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

kubectl --kubeconfig <project-kubeconfig> get pods -n argocd

List Argo CD applications:

kubectl --kubeconfig <project-kubeconfig> get applications -n argocd

Inspect the application:

kubectl --kubeconfig <project-kubeconfig> get application azure-webapp -n argocd

Describe the application:

kubectl --kubeconfig <project-kubeconfig> describe application azure-webapp -n argocd

Validate the application Deployment:

kubectl --kubeconfig <project-kubeconfig> get deployment azure-webapp

Validate the application Pods:

kubectl --kubeconfig <project-kubeconfig> get pods
Drift Reconciliation Test

A controlled reconciliation test in an approved non-production environment can temporarily change the Deployment replica count:

kubectl --kubeconfig <project-kubeconfig> scale deployment azure-webapp --replicas=3

When self-healing is enabled, Argo CD should return the Deployment to the replica count defined in Git.

Validate:

kubectl --kubeconfig <project-kubeconfig> get deployment azure-webapp
Evidence







Outcome

This phase documents the GitOps operating model. Confirm the live sync, health, and self-healing results through the current validation record.
