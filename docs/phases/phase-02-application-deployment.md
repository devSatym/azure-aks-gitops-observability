Phase 2 — Containerised Application Deployment
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

Example workload structure:

apiVersion: apps/v1
kind: Deployment
metadata:
  name: ram-webapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ram-webapp
  template:
    metadata:
      labels:
        app: ram-webapp
    spec:
      containers:
        - name: ram-webapp
          image: <acr-login-server>/ram-aks-web:<image-tag>
          ports:
            - containerPort: 80
Kubernetes Service

A Kubernetes Service exposes the application:

apiVersion: v1
kind: Service
metadata:
  name: ram-webapp-service
spec:
  type: LoadBalancer
  selector:
    app: ram-webapp
  ports:
    - port: 80
      targetPort: 80

The Service selector must match the Pod label:

app: ram-webapp
Initial Deployment

Apply the Kubernetes configuration:

kubectl apply -f <manifest-file>.yaml
Workload Validation

Validate the Deployment:

kubectl get deployments

Validate the Pods:

kubectl get pods

Validate the Service:

kubectl get svc

Validate the application rollout:

kubectl rollout status deployment/ram-webapp

Expected states:

Deployment: Available
Pod: Running
Service: External IP assigned
Rollout: Successfully completed
Troubleshooting Commands

Inspect a Pod:

kubectl describe pod <pod-name>

View container logs:

kubectl logs <pod-name>

Inspect the Deployment:

kubectl describe deployment ram-webapp
Evidence







Outcome

This phase confirmed that the application image could be retrieved from ACR, deployed to AKS and accessed externally through a LoadBalancer Service.