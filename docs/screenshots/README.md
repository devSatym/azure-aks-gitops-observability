# Fresh Evidence Checklist

The numbered PNG files already in this directory are inherited assets. They are
not evidence for the current Azure environment and must not be cited as such.
Capture the exact filenames below only after the corresponding validation is
visible.

## Redaction rules

- Do not expose client secrets, access tokens, storage keys, kubeconfigs,
  GitHub Actions secret values, or Action Group recipient addresses.
- Redact unrelated subscription, tenant, account, repository, or cluster data.
- A project resource name, immutable image tag, Git commit, public service IP,
  dashboard title, and non-secret Azure resource identifier may remain visible
  when needed for traceability.
- Include a clock or portal timestamp where it helps correlate delayed Azure
  Monitor results.

## Required fresh captures

| File | What to open | What must be visible | Why it matters / hide |
| --- | --- | --- | --- |
| `01-terraform-apply.png` | Terminal/CI record of reviewed Terraform apply | Intended changes and no secret/backend input | Proves infrastructure ownership; hide sensitive local paths and recipient input. |
| `02-azure-aks-acr.png` | Azure portal resource group or AKS/ACR overview | Project AKS and ACR provisioned; ACR admin disabled if practical | Proves Azure ownership; hide unrelated resources. |
| `03-github-actions-cicd.png` | Successful canary GitHub Actions run | OIDC, build, ACR push, Helm update, bot commit | Proves CI ownership boundary; hide values. |
| `04-acr-sha-image.png` | ACR repository/tag or Azure CLI output | `azure-webapp` immutable source SHA tag | Correlates source to image; no credentials. |
| `05-gitops-commit.png` | Bot commit diff | Only `helm/azure-webapp/values.yaml:image.tag` changes | Proves CI promotes Git instead of deploying. |
| `06-argocd-canary-synced-healthy.png` | Argo UI/Application status | `azure-webapp`, Synced, Healthy, revision | Proves canary reconciliation. |
| `07-live-canary.png` | Browser/curl through canary LoadBalancer | Delivery-verification marker and response | Proves canary reachability. |
| `08-argocd-self-healing.png` | Argo UI/status and Deployment watch | Temporary OutOfSync drift followed by desired replica restoration | Proves self-heal; leave no drift active. |
| `09-container-insights.png` | Azure Container Insights | Current nodes/controllers/containers/pods | Proves platform telemetry; hide account information. |
| `10-log-analytics-kql.png` | Log Analytics query results | Current `KubePodInventory`/ `KubeNodeInventory` rows | Proves KQL platform data. |
| `11-azure-monitor-alert-rules.png` | Azure Monitor rules and Action Group | Enabled rules, schedules/windows, action association | Proves alert configuration; redact recipient. |
| `12-fired-alert.png` | Azure Monitor fired-alert details | Controlled failure correlation and fired rule | Proves end-to-end alerting; redact recipient/message metadata. |
| `13-managed-prometheus.png` | Azure Monitor workspace PromQL result | Current `otel-demo` series such as `demo.payment.transactions` | Proves managed metrics; hide account data. |
| `14-argocd-otel-synced-healthy.png` | Argo UI/Application status | `opentelemetry-demo`, Synced, Healthy, revision | Proves primary workload reconciliation. |
| `15-otel-demo-loadbalancer.png` | Browser/curl through `frontend-proxy` | HTTP 200/demo storefront response | Proves primary workload reachability. |
| `16-native-otel-kql.png` | Log Analytics `OTel*` query | Current spans/logs/events/resources and service names | Proves native OTLP ingestion; do not use classic `App*` tables. |
| `17-payment-fault-restored.png` | KQL/portal evidence plus restored configuration | Error telemetry in bounded window and flag returned to `off` | Proves controlled application-error detection and cleanup. |

## Current evidence state

The canary delivery and self-heal, Container Insights, KQL alerting,
recipient-confirmed Action Group email, managed Prometheus, Argo-managed OTel
Demo, native `OTel*` ingestion, and the restored payment-failure test are
recorded in [`docs/codex/03-VALIDATION.md`](../codex/03-VALIDATION.md). Fresh
owner screenshots remain outstanding.
