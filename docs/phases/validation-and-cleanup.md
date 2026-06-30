Platform Validation and Cleanup
Objective

This guide contains the commands used to validate the complete AKS platform and safely remove the resources when they are no longer required.

1. Azure Infrastructure Validation

List resources in the resource group:

az resource list \
  --resource-group <resource-group-name> \
  --output table

Validate AKS:

az aks show \
  --resource-group <resource-group-name> \
  --name <aks-cluster-name> \
  --output table

Validate ACR:

az acr show \
  --name <acr-name> \
  --output table
2. AKS Node Validation
kubectl get nodes

Expected state:

STATUS: Ready

View additional node details:

kubectl get nodes -o wide
3. Kubernetes Workload Validation
kubectl get deployments
kubectl get pods
kubectl get svc
kubectl rollout status deployment/azure-webapp

These commands validate that:

The Deployment exists
The required replica is available
The application Pod is running
The LoadBalancer Service is available
The application rollout completed successfully
4. Pod Troubleshooting

Describe the Pod:

kubectl describe pod <pod-name>

View logs:

kubectl logs <pod-name>

View recent Kubernetes events:

kubectl get events \
  --sort-by=.metadata.creationTimestamp
5. Self-Healing Validation

Delete an application Pod:

kubectl delete pod <pod-name>

Check the Pods again:

kubectl get pods

The Deployment controller should automatically create a replacement Pod.

This validates Kubernetes self-healing at the workload level.

6. Rollout Validation
kubectl rollout status deployment/azure-webapp

View rollout history:

kubectl rollout history deployment/azure-webapp
7. Azure Container Registry Validation

List repositories:

az acr repository list \
  --name <acr-name> \
  --output table

List application image tags:

az acr repository show-tags \
  --name <acr-name> \
  --repository azure-webapp \
  --output table
8. Helm Validation

List Helm releases:

helm list

Check the application release:

helm status azure-webapp

View release history:

helm history azure-webapp

Validate the chart:

helm lint ./helm/azure-webapp

Render the templates locally:

helm template azure-webapp ./helm/azure-webapp
9. Argo CD Validation

Check Argo CD Pods:

kubectl get pods -n argocd

List Argo CD applications:

kubectl get applications -n argocd

Inspect the application:

kubectl get application azure-webapp -n argocd

Expected state:

Sync Status: Synced
Health Status: Healthy
10. Monitoring Validation

Check Kubernetes system and workload Pods:

kubectl get pods --all-namespaces

Check the monitoring namespace:

kubectl get pods -n monitoring

Check the Prometheus Helm release:

helm list -n monitoring
11. Grafana Access
kubectl port-forward \
  svc/kube-prometheus-stack-grafana \
  3000:80 \
  -n monitoring

Open:

http://localhost:3000
12. Argo CD Drift Test

Change the Deployment directly:

kubectl scale deployment azure-webapp --replicas=3

Check the Deployment:

kubectl get deployment azure-webapp

When Argo CD self-healing is enabled, it should return the Deployment to the replica count defined in Git.

13. Application Availability

Retrieve the Service external IP:

kubectl get svc azure-webapp-service

Open the external IP in a browser.

Cleanup
Remove the Application Helm Release

Only run this when Helm directly owns the release:

helm uninstall azure-webapp

When Argo CD owns the release, delete or disable the Argo CD application first.

Remove Prometheus and Grafana
helm uninstall kube-prometheus-stack -n monitoring
kubectl delete namespace monitoring
Remove Argo CD
kubectl delete namespace argocd
Destroy Azure Infrastructure

Run from the Terraform root directory:

terraform destroy

Review the destruction plan before confirming.

Cost-Control Recommendation

AKS worker nodes generate costs while the cluster is running.

For learning environments:

Capture the required screenshots and validation evidence.
Confirm that all configuration is committed to Git.
Run terraform destroy.
Recreate the environment later using terraform apply.
Outcome

These checks validate the infrastructure, application, CI, Helm, monitoring and GitOps layers before the environment is removed.
