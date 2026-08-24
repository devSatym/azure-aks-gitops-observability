# Fresh Evidence Checklist

The numbered PNG files already in this directory are inherited assets. They are not evidence for the current Azure environment and must not be cited as such. Capture new screenshots only after the corresponding validation is observed, using a distinct `live-` filename.

## Redaction Rules

- Do not expose client secrets, access tokens, storage keys, kubeconfigs, Grafana passwords, or GitHub Actions secret values.
- Redact the Action Group recipient address and any unrelated subscription, tenant, account, repository, or cluster data.
- A resource name, immutable image tag, Git commit, service IP, dashboard title, and non-secret Azure resource identifier may remain visible when needed to establish traceability.
- Include a clock or portal timestamp where it helps correlate a delayed Azure Monitor result.

## Required Fresh Captures

| Suggested file | Visible proof | Gate |
| --- | --- | --- |
| `live-01-repository-workflow.png` | Fork, `main`, workflow file, Helm-only image source | Source review |
| `live-02-actions-oidc-success.png` | Successful first workflow job with OIDC, build, push, and GitOps update steps | CI run |
| `live-03-terraform-apply-or-rg.png` | Project resource group and the provisioned AKS/ACR/Log Analytics resources | Terraform apply |
| `live-04-aks-nodes.png` | Two Ready AKS nodes or the AKS overview | Cluster baseline |
| `live-05-acr-sha-image.png` | `azure-webapp` repository with the immutable source SHA tag | ACR validation |
| `live-06-gitops-commit.png` | Bot commit changing only `helm/azure-webapp/values.yaml:image.tag` | GitOps validation |
| `live-07-argocd-synced-healthy.png` | `azure-webapp` Application Synced and Healthy at the GitOps revision | Argo validation |
| `live-08-app-loadbalancer.png` | Public service response containing the delivery-verification marker | Workload validation |
| `live-09-argocd-self-heal.png` | OutOfSync drift followed by restoration to the Git-defined replica count | Drift test |
| `live-10-container-insights.png` | Current cluster/workload records in Container Insights | Telemetry ingestion |
| `live-11-log-analytics-kql.png` | Successful current `KubePodInventory`/`KubeNodeInventory` query results | KQL validation |
| `live-12-alert-rules-and-fired-alert.png` | Three enabled rules, Action Group (recipient redacted), and controlled fired alert | Alert validation |
| `live-13-prometheus-grafana.png` | Healthy Prometheus targets and a populated Kubernetes Grafana dashboard | Metrics validation |

## Current Evidence State

The first CI-to-GitOps delivery, Argo self-heal, and Prometheus/Grafana baseline have command evidence in `docs/codex/03-VALIDATION.md`. Fresh owner-captured screenshots remain outstanding. Container Insights records, KQL results, and a delivered controlled alert must appear before the related captures are marked complete.
