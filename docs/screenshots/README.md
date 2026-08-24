# Fresh Evidence Checklist

The numbered PNG files already in this directory are inherited assets. They are not evidence for the current Azure environment and must not be cited as such. Replace or capture the exact filenames below only after the corresponding validation is observed.

## Redaction Rules

- Do not expose client secrets, access tokens, storage keys, kubeconfigs, Grafana passwords, or GitHub Actions secret values.
- Redact the Action Group recipient address and any unrelated subscription, tenant, account, repository, or cluster data.
- A resource name, immutable image tag, Git commit, service IP, dashboard title, and non-secret Azure resource identifier may remain visible when needed to establish traceability.
- Include a clock or portal timestamp where it helps correlate a delayed Azure Monitor result.

## Required Fresh Captures

| File | What to open | What must be visible | Why it matters / hide |
| --- | --- | --- | --- |
| `01-terraform-apply.png` | Terminal/CI record of reviewed `terraform apply tfplan` | `13 added, 0 changed, 0 destroyed` | Proves infrastructure was applied; hide recipient input and backend paths if shown. |
| `02-azure-aks-acr.png` | Azure portal resource group or AKS/ACR overview | Project AKS and ACR are provisioned; ACR admin is disabled if practical | Proves Azure resource ownership; hide unrelated subscriptions/resources. |
| `03-github-actions-cicd.png` | Successful first GitHub Actions run | OIDC, build, ACR push, Helm update, and bot commit steps | Proves CI ownership boundary; hide secret values. |
| `04-acr-sha-image.png` | ACR repository/tag or Azure CLI output | `azure-webapp` with the immutable source SHA tag | Correlates source to image; do not show credentials. |
| `05-gitops-commit.png` | Bot commit diff in GitHub | Only `helm/azure-webapp/values.yaml:image.tag` changes | Proves CI promotes Git rather than deploying directly. |
| `06-argocd-synced-healthy.png` | Argo CD Application UI or Kubernetes Application status | `azure-webapp`, Synced, Healthy, and GitOps revision | Proves Argo owns deployment; hide local URLs/tokens. |
| `07-live-application.png` | Browser/curl response through the LoadBalancer | Delivery-verification marker and successful response | Proves deployed workload is reachable; redact any unrelated browser/account data. |
| `08-argocd-self-healing.png` | Argo UI/status and deployment watch | Temporary OutOfSync drift followed by desired replica restoration | Proves automated self-heal; do not leave drift active for the screenshot. |
| `09-container-insights.png` | Azure Container Insights for this AKS cluster | Current nodes/controllers/containers/pods | Proves Azure-native telemetry; hide recipient/account information. |
| `10-log-analytics-kql.png` | Log Analytics query results | Current `KubePodInventory` and/or `KubeNodeInventory` records | Proves actual KQL data rather than configuration; redact sensitive fields. |
| `11-azure-monitor-alert-rules.png` | Azure Monitor rule and Action Group pages | Three enabled rules, schedules/windows, and action association | Proves alert configuration; redact the receiver email. |
| `12-fired-alert.png` | Azure Monitor fired-alert details and notification evidence | Controlled failure correlation, fired rule, and recipient confirmation | Proves end-to-end alerting; redact the recipient email and message metadata. |
| `13-grafana-dashboard.png` | Grafana via local port-forward | Populated supplied Kubernetes cluster/node/namespace/pod view | Proves metrics dashboards; hide the generated Grafana password or auth material. |

## Current Evidence State

The first CI-to-GitOps delivery, Argo self-heal, Prometheus/Grafana baseline, Container Insights records, KQL results, a real controlled scheduled-query alert, and recipient-confirmed Action Group email delivery have evidence in `docs/codex/03-VALIDATION.md`. Fresh owner-captured screenshots remain outstanding.
