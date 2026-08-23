# Repository Audit

Date: 2026-08-23
Scope: local repository at the start of the Azure AKS GitOps CI/CD & Observability implementation.

## Repository and Git State

- Active branch: `main`.
- Configured remote: `https://github.com/devSatym/azure-aks-gitops-observability.git`.
- Existing untracked file: `plan.md`. It is the user-provided implementation brief and has been preserved.
- No `AGENTS.md`, Terraform lock file, local backend file, local tfvars file, or Terraform state file is present.
- Azure CLI and GitHub CLI are not installed in this environment. Azure account, subscription, deployed resources, GitHub secrets, repository variables, and workflow runs cannot be verified locally yet.

## Structure

```text
.
├── .github/workflows/deploy-aks.yml
├── app/                         # static nginx application and Dockerfile
├── argocd/                      # Argo CD Application manifest
├── helm/azure-webapp/            # active Helm chart candidate
├── k8s/                          # legacy raw manifests; not referenced by live code
├── modules/                      # Terraform modules
├── docs/phases/                  # historical phase documentation
├── docs/screenshots/             # existing, unverified screenshot assets
├── main.tf, providers.tf, variables.tf, outputs.tf
└── README.md
```

## Current Architecture Verified in Code

Terraform composes a resource group, VNet (`10.20.0.0/16`), AKS subnet (`10.20.1.0/24`), Basic ACR, Log Analytics workspace, AKS cluster, Action Group, and three scheduled-query alerts. AKS uses a system-assigned control-plane identity, Azure CNI, a Standard load balancer, one configurable node pool, and the OMS agent connected to the workspace. The kubelet identity receives `AcrPull` on the ACR. ACR admin credentials are disabled.

The application is a static nginx page. The Helm chart renders a Deployment and a LoadBalancer Service. The Argo CD Application is configured for automated sync, pruning, and self-heal, but its Helm parameters override the chart's image values. GitHub Actions currently authenticates through Azure OIDC, builds a seven-character-SHA-tagged image, pushes it to ACR, then retrieves AKS credentials. It does not change Git desired state or deploy anything after retrieving credentials.

## Terraform Audit

| Area | Verified state | Finding |
| --- | --- | --- |
| Terraform | `>= 1.6.0`; local CLI is 1.15.8 | No initialization or validation has run yet. |
| Providers | `azurerm ~> 4.0`, `random ~> 3.6` | Lock file is incorrectly ignored and absent. |
| Backend | AzureRM backend hardcoded in `providers.tf` | References `rg-terraform-state`, `sttfstatram2026`, container `tfstate`, and key `aks-platform/terraform.tfstate`; must be replaced by an empty backend plus ignored local config. |
| Identity | AKS system identity plus kubelet identity | `AcrPull` is correctly scoped to the created ACR. |
| Monitoring | `oms_agent` with workspace ID | Managed-identity monitoring authentication support has not yet been checked against the installed AzureRM provider schema. |
| Alerts | Node non-Ready, failed/CrashLoop pod, and restart-count rules | Each evaluates every 5 minutes over 15 minutes and sends email through one Action Group. Actual table ingestion/schema and alert firing remain untested. |
| Inputs | location, project name, environment, node count/size, alert email | `alert_email` has no default, so an example tfvars file is needed. |
| Naming | random six-character suffixes | Supports unique resource names. `Owner = devSatym` is project-specific but is not an upstream name and will be retained unless the owner asks for a different tag policy. |

## CI/CD and GitOps Audit

| Area | Verified state | Required correction |
| --- | --- | --- |
| Workflow | `.github/workflows/deploy-aks.yml` runs on `main` app/workflow changes | Rename its displayed purpose to build, push, and update GitOps; add write permission and safe concurrency. |
| Azure auth | `azure/login@v2` with client, tenant, subscription IDs | This is OIDC-compatible and has no client secret in code. Federated credential and RBAC are not yet verified. |
| ACR delivery | Build and push use `GITHUB_SHA::7` | Retain immutable tag, then write it to Helm `image.tag`. |
| CI permissions | `id-token: write`, `contents: read` | Set `contents: write` so the workflow can commit its desired-state update. |
| CI AKS access | Loads `AKS_RESOURCE_GROUP`, `AKS_CLUSTER_NAME`, and `DEPLOYMENT_NAME`; calls `az aks get-credentials` | Remove. CI must not require routine AKS administration after GitOps handoff. |
| Helm | Chart is named `azure-webapp`; values use empty repository and `latest` | Make values the single image source. The real ACR login server is only knowable after Terraform deployment; use a clearly documented bootstrap placeholder before then. |
| Argo CD | Repo URL points to nonexistent/outdated `devSatym/azure-aks-terraform-cicd-monitoring`; image overrides reference upstream ACR and `v1` | Point to the actual origin repository and remove image parameters. |
| Raw manifests | `k8s/azure-webapp.yaml` and `k8s/nginx.yaml` | Neither is referenced by workflow, Argo, or Terraform. They compete with Helm and contain stale ACR / `latest` references; retire them after the Helm chart validates. |

## Application and Documentation Audit

- `app/index.html` has two stray headings after `</html>` and describes direct GitHub Actions deployment. It needs a minimal GitOps/observability presentation.
- The README accurately names many intended components but makes completed/validated claims that local code and available tools do not prove. It still describes a "platform," publishes inherited screenshots as project evidence, documents legacy raw-manifest/Helm direct deployment, lists intentionally excluded technologies as future improvements, and omits the CI-to-Git desired-state update.
- Phase documents are historical narrative, not evidence-backed validation. Several instruct direct `kubectl apply` or Helm deployment; these conflict with the final Argo-owned deployment model.
- Existing `docs/screenshots/*.png` are inherited assets. They cannot be treated as evidence of this Azure environment until the owner captures fresh screenshots.
- No Prometheus/Grafana or Argo installation manifests/scripts are present; both must be installed with Helm only after AKS is available.

## Hardcoded / Stale Values Found

| File | Value or behavior | Classification |
| --- | --- | --- |
| `providers.tf` | `rg-terraform-state`, `sttfstatram2026`, `aks-platform/terraform.tfstate` | upstream environment coupling |
| `argocd/azure-webapp-application.yaml` | old fork URL, `acraksdemodevjv094d.azurecr.io/azure-webapp`, `v1` | stale GitOps source and image override |
| `k8s/azure-webapp.yaml` | `acraksdemodevaafof8.azurecr.io/azure-webapp:v1` | legacy deployment configuration |
| `k8s/nginx.yaml` | `nginx:latest` | legacy manifest / mutable tag |
| `helm/azure-webapp/values.yaml` | empty repository, `latest` | invalid final desired state |
| `.gitignore` | ignores `.terraform.lock.hcl`; does not ignore `backend.hcl` | lock-file and local-backend hygiene issue |
| workflow | retrieves AKS credentials but never uses them | unnecessary direct cluster access |

## Security and Authentication Model

- Desired CI model: GitHub OIDC federation to a Microsoft Entra application, with `AcrPush` scoped to the project ACR.
- Current workflow has the right OIDC action inputs and no client secret in repository code.
- ACR admin authentication is disabled, and AKS receives `AcrPull` through the kubelet identity.
- The current workflow's AKS credential retrieval is over-privileged for its real responsibility and will be removed.
- No credentials, tokens, state, or kubeconfig were found in tracked files.

## Files Expected to Change

- `.gitignore`, `providers.tf`, `backend.hcl.example`, `terraform.tfvars.example`.
- `modules/aks/main.tf` only if provider-schema verification supports managed-identity monitoring authentication.
- `app/index.html`, Helm values/templates as justified, Argo Application, GitHub workflow.
- Removal of `k8s/` after rendered Helm equivalence is verified.
- README and final operational documentation, including this directory.

## Files Expected to Remain Functionally Unchanged

- Terraform resource-group, network, ACR, monitoring, and alert-module architecture, except validated compatibility or documentation corrections.
- The simple nginx Dockerfile and the fixed AKS-to-ACR `AcrPull` relationship.
- Existing upstream license/copyright material: none was found in this checkout, so no license will be added on the upstream author's behalf.

## Audit Conclusion

The repository has the intended building blocks but is not yet a finished GitOps project. The smallest safe path is to remove ownership coupling, make Helm values the sole image source, convert CI to artifact build/push plus Git update, and then perform evidence-backed cloud validation after Azure tooling and user authentication are available.
