# Phase 2 — Containerised Application Deployment

> Historical and superseded deployment stage. Raw Kubernetes manifests are not the supported application delivery path in this repository. The application is rendered from `helm/azure-webapp` and reconciled by Argo CD; use Git changes to its desired state rather than applying manifests directly.

Objective

The objective of this phase was to package a sample web application as a Docker container and deploy it to Azure Kubernetes Service.

This phase validated that AKS could pull the image from Azure Container Registry, create application Pods and expose the application through a Kubernetes LoadBalancer Service.

Application Components

The workload consists of:

A sample web application
Dockerfile
Docker image
Azure Container Registry repository
Kubernetes Deployment
Application Pods
Kubernetes LoadBalancer Service
Application Deployment Flow
Application Source Code
   ↓
Docker Build
   ↓
Container Image
   ↓
Azure Container Registry
   ↓
Kubernetes Deployment
   ↓
Application Pod
   ↓
LoadBalancer Service
   ↓
External Application Access
Kubernetes Deployment

The Kubernetes Deployment defines:

Application name
Container image
Replica count
Container port
Pod labels
Deployment selector

Illustrative workload structure (not a deployable repository manifest):

apiVersion: apps/v1
kind: Deployment
metadata:
  name: azure-webapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: azure-webapp
  template:
    metadata:
      labels:
        app: azure-webapp
    spec:
      containers:
        - name: azure-webapp
          image: <acr-login-server>/azure-webapp:<image-tag>
          ports:
            - containerPort: 80
Kubernetes Service

A Kubernetes Service exposes the application:

apiVersion: v1
kind: Service
metadata:
  name: azure-webapp-service
spec:
  type: LoadBalancer
  selector:
    app: azure-webapp
  ports:
    - port: 80
      targetPort: 80

The Service selector must match the Pod label:

app: azure-webapp
Current Delivery Path

The supported path is:

Application source change
   ↓
GitHub Actions builds and pushes an immutable image to ACR
   ↓
GitHub Actions commits the image tag to Helm desired state
   ↓
Argo CD reconciles the Helm chart into AKS

Do not deploy or update `azure-webapp` with raw manifests or direct `kubectl` workload commands.

Workload Validation

Validate the Deployment:

kubectl --kubeconfig <project-kubeconfig> get deployments

Validate the Pods:

kubectl --kubeconfig <project-kubeconfig> get pods

Validate the Service:

kubectl --kubeconfig <project-kubeconfig> get svc

Validate the application rollout:

kubectl --kubeconfig <project-kubeconfig> rollout status deployment/azure-webapp

Expected states:

Deployment: Available
Pod: Running
Service: External IP assigned
Rollout: Successfully completed
Troubleshooting Commands

Inspect a Pod:

kubectl --kubeconfig <project-kubeconfig> describe pod <pod-name>

View container logs:

kubectl --kubeconfig <project-kubeconfig> logs <pod-name>

Inspect the Deployment:

kubectl --kubeconfig <project-kubeconfig> describe deployment azure-webapp
Evidence







Outcome

This historical phase explains the workload components. Current delivery and availability claims must be backed by the GitOps and validation records, not this guide.
