# Platform Validation and Cleanup

> Historical runbook. Review the current validation and cleanup guidance in the
> root README and `docs/codex/05-HANDOFF.md` before making any write or
> deletion. The self-hosted Prometheus/Grafana sections below are retired; the
> current environment uses managed Prometheus and native OTLP. Argo CD-owned
> applications must not be deployed, upgraded, rolled back, or uninstalled as
> direct Helm releases. Set `PROJECT_KUBECONFIG` to a dedicated AKS kubeconfig
> before using any Kubernetes command below.

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
kubectl --kubeconfig "$PROJECT_KUBECONFIG" get nodes

Expected state:

STATUS: Ready

View additional node details:

kubectl --kubeconfig "$PROJECT_KUBECONFIG" get nodes -o wide
3. Kubernetes Workload Validation
kubectl --kubeconfig "$PROJECT_KUBECONFIG" get deployments
kubectl --kubeconfig "$PROJECT_KUBECONFIG" get pods
kubectl --kubeconfig "$PROJECT_KUBECONFIG" get svc
kubectl --kubeconfig "$PROJECT_KUBECONFIG" rollout status deployment/azure-webapp

These commands validate that:

The Deployment exists
The required replica is available
The application Pod is running
The LoadBalancer Service is available
The application rollout completed successfully
4. Pod Troubleshooting

Describe the Pod:

kubectl --kubeconfig "$PROJECT_KUBECONFIG" describe pod <pod-name>

View logs:

kubectl --kubeconfig "$PROJECT_KUBECONFIG" logs <pod-name>

View recent Kubernetes events:

kubectl --kubeconfig "$PROJECT_KUBECONFIG" get events \
  --sort-by=.metadata.creationTimestamp
5. Self-Healing Validation

For a controlled, approved non-production test only, delete an application Pod:

kubectl --kubeconfig "$PROJECT_KUBECONFIG" delete pod <pod-name>

Check the Pods again:

kubectl --kubeconfig "$PROJECT_KUBECONFIG" get pods

The Deployment controller should automatically create a replacement Pod.

This validates Kubernetes self-healing at the workload level.

6. Rollout Validation
kubectl --kubeconfig "$PROJECT_KUBECONFIG" rollout status deployment/azure-webapp

View rollout history:

kubectl --kubeconfig "$PROJECT_KUBECONFIG" rollout history deployment/azure-webapp
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
8. Helm Chart Validation

The application does not have a directly operated Helm release: Argo CD renders and reconciles the chart. Validate the chart without deploying it:

helm lint ./helm/azure-webapp

Render the templates locally:

helm template azure-webapp ./helm/azure-webapp
9. Argo CD Validation

Check Argo CD Pods:

kubectl --kubeconfig "$PROJECT_KUBECONFIG" get pods -n argocd

List Argo CD applications:

kubectl --kubeconfig "$PROJECT_KUBECONFIG" get applications -n argocd

Inspect the application:

kubectl --kubeconfig "$PROJECT_KUBECONFIG" get application azure-webapp -n argocd

Expected state:

Sync Status: Synced
Health Status: Healthy
10. Monitoring Validation

Check Kubernetes system and workload Pods:

kubectl --kubeconfig "$PROJECT_KUBECONFIG" get pods --all-namespaces

Check the monitoring namespace:

kubectl --kubeconfig "$PROJECT_KUBECONFIG" get pods -n monitoring

Check the Prometheus Helm release:

helm list -n monitoring --kubeconfig "$PROJECT_KUBECONFIG"
11. Grafana Access
kubectl --kubeconfig "$PROJECT_KUBECONFIG" port-forward \
  svc/kube-prometheus-stack-grafana \
  3000:80 \
  -n monitoring

Open:

http://localhost:3000
12. Argo CD Drift Test

In a controlled, approved non-production test, change the Deployment directly:

kubectl --kubeconfig "$PROJECT_KUBECONFIG" scale deployment azure-webapp --replicas=3

Check the Deployment:

kubectl --kubeconfig "$PROJECT_KUBECONFIG" get deployment azure-webapp

When Argo CD self-healing is enabled, it should return the Deployment to the replica count defined in Git.

13. Application Availability

Retrieve the Service external IP:

kubectl --kubeconfig "$PROJECT_KUBECONFIG" get svc azure-webapp-service

Open the external IP in a browser.

Cleanup

> Destructive operations: do not run any command in this section without explicit approval, a reviewed target, and retained evidence/state as required.

Remove the Argo CD application first. Prefer a reviewed Git change that removes or disables the `Application`; if deleting it directly, first confirm the intended cascading-resource behavior:

kubectl --kubeconfig "$PROJECT_KUBECONFIG" delete application azure-webapp -n argocd

Remove Prometheus and Grafana:

helm uninstall kube-prometheus-stack --namespace monitoring --kubeconfig "$PROJECT_KUBECONFIG"

Remove Argo CD:

Identify the installed release first, then uninstall that reviewed release:

helm list --namespace argocd --kubeconfig "$PROJECT_KUBECONFIG"
helm uninstall <argo-cd-release> --namespace argocd --kubeconfig "$PROJECT_KUBECONFIG"

Destroy Azure Infrastructure

Run from the Terraform root directory:

terraform destroy

Review the destruction plan before confirming. Do not run it without explicit approval.

Retain the remote Terraform backend until the destroy outcome and required audit records are verified. Delete the backend storage only when its retained state is no longer needed.

Cost-Control Recommendation

AKS worker nodes generate costs while the cluster is running.

For learning environments:

Capture the required screenshots and validation evidence.
Confirm that all configuration is committed to Git.
Run `terraform destroy` only after explicit approval.
Recreate the environment later using terraform apply.
Outcome

Use these checks as a historical reference. The current evidence record, GitOps ownership model, and approved cleanup plan determine what is actually safe to validate or remove.
