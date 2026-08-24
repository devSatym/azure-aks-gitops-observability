# Azure AKS GitOps CI/CD & Observability

Azure | Terraform | AKS | ACR | GitHub Actions | OIDC | Docker | Kubernetes | Helm | Argo CD | Azure Monitor | Log Analytics | KQL | OpenTelemetry | Managed Prometheus

- Provisioned a modular Azure environment with Terraform: Azure CNI AKS, ACR, VNet/subnet, Log Analytics, Application Insights, Azure Monitor workspace, managed Prometheus and native-OTLP DCR resources, Action Group, three scheduled-query alert rules, scoped RBAC, and Container Insights DCR/DCRA; final Terraform validation reported no drift.
- Implemented passwordless GitHub Actions delivery with Microsoft Entra OIDC and ACR-scoped `AcrPush`, building and publishing the immutable `azure-webapp:9d37a77` image without a client secret or ACR admin credential.
- Established a CI-to-GitOps handoff in which CI changes only Helm `image.tag` and Argo CD owns deployment, prune, and self-healing; a controlled scale drift from four to two replicas was restored in 28 seconds.
- Migrated the primary workload to the official OpenTelemetry Demo with an Entra/workload-identity authenticated Collector gateway; validated live managed-Prometheus metrics, native `OTel*` spans/logs/events/resources, and a restored controlled payment-failure trace while keeping the two-node cluster within its 60-pod quota.

Evidence and current runtime-alert status: [`docs/codex/03-VALIDATION.md`](codex/03-VALIDATION.md).
