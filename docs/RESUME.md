# Azure AKS GitOps CI/CD & Observability

Azure | Terraform | AKS | ACR | GitHub Actions | OIDC | Docker | Kubernetes | Helm | Argo CD | Azure Monitor | Log Analytics | KQL | Prometheus | Grafana

- Provisioned a modular Azure environment with Terraform: Azure CNI AKS, ACR, VNet/subnet, Log Analytics, Action Group, three scheduled-query alert rules, scoped AKS RBAC, and the Container Insights DCR/DCRA; final Terraform validation reported no drift.
- Implemented passwordless GitHub Actions delivery with Microsoft Entra OIDC and ACR-scoped `AcrPush`, building and publishing the immutable `azure-webapp:9d37a77` image without a client secret or ACR admin credential.
- Established a CI-to-GitOps handoff in which CI changes only Helm `image.tag` and Argo CD owns deployment, prune, and self-healing; a controlled scale drift from four to two replicas was restored in 28 seconds.
- Validated Kubernetes observability with Container Insights pod/node KQL records, a real fired Azure Monitor failed-pod alert with recipient-confirmed Action Group email delivery, Prometheus 18/18 active targets, an application replica metric, and Grafana's supplied Kubernetes dashboards.

Evidence and current runtime-alert status: [`docs/codex/03-VALIDATION.md`](codex/03-VALIDATION.md).
