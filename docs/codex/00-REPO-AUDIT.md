# Repository Audit

Date: 2026-08-24
Scope: current checkout of Azure AKS GitOps CI/CD & Observability before any new Azure-side mutation.

## Audit Method and Git State

- Inspected every tracked Terraform root/module file, workflow, Helm chart template/value, Argo CD Application, application file, phase document, README, ignore rule, and provider lock file.
- Ran the required ownership/deployment searches. `plan.md` is an untracked user-provided brief and was deliberately left untouched.
- No repository `AGENTS.md` exists. The active branch is `main`; its only remote is `https://github.com/devSatym/azure-aks-gitops-observability.git`.
- The seven reviewed source-reconciliation commits have been pushed to `origin/main`. The worktree is otherwise clean apart from `plan.md`.
- The prior audit text described the upstream starting point. This document is the reconciled, current-state audit; historical upstream values remain documented only as migration history.

## Repository Structure

```text
.
├── .github/workflows/deploy-aks.yml      # CI build/push/GitOps promotion
├── app/                                  # static nginx application
├── argocd/                               # Argo CD Application
├── helm/azure-webapp/                    # sole active deployment definition
├── modules/                              # Terraform modules
├── docs/codex/                           # live audit, plan, status, evidence, decisions, handoff
├── docs/phases/                          # inherited historical guides; not current evidence
├── docs/screenshots/                     # inherited, unverified image assets
├── main.tf, providers.tf, variables.tf, outputs.tf
├── backend.hcl.example
└── terraform.tfvars.example
```

There is no `k8s/` directory in the current checkout. The legacy raw manifests were removed in local commit `72f0869` after Helm lint/template validation.

## Current Architecture Verified in Code

Terraform creates one resource group, VNet (`10.20.0.0/16`), AKS subnet (`10.20.1.0/24`), Basic ACR with admin credentials disabled, Log Analytics workspace, AKS cluster, Action Group, and three scheduled-query alert rules. AKS uses a system-assigned identity, Azure CNI, Standard Load Balancer, one configurable node pool, the OMS agent, and managed-identity monitoring authentication. The AKS kubelet identity receives `AcrPull` scoped to the created ACR.

The application is a deliberately simple nginx page. The Helm chart renders one two-replica Deployment and one LoadBalancer Service. `argocd/azure-webapp-application.yaml` targets this fork and chart with automated sync, prune, and self-heal. GitHub Actions uses Azure OIDC, builds and pushes a seven-character-SHA tag, changes only Helm `image.tag`, then commits/pushes that desired-state change. It contains no AKS credential, Helm upgrade, `kubectl apply`, or Argo sync step.

## Terraform Audit

| Area | Verified current state | Result / follow-up |
| --- | --- | --- |
| Terraform | Required version `>= 1.6.0`; local CLI 1.15.8 | `fmt`, backend-disabled init, and `validate` pass. |
| Providers | AzureRM `~> 4.0`, Random `~> 3.6`; lock pins 4.81.0 / 3.9.0 | Lock file is tracked. |
| Backend | `backend "azurerm" {}` only | Environment-specific backend is correctly delegated to ignored `backend.hcl`. No remote backend exists yet. |
| Input examples | `backend.hcl.example` and `terraform.tfvars.example` exist | Both contain placeholders/examples only. A real ignored `terraform.tfvars` still needs an alert recipient. |
| AKS/ACR identity | `AcrPull` uses the kubelet object ID and ACR scope | Correct least-privilege pull relationship; apply-time validation remains pending. |
| Monitoring auth | `oms_agent.msi_auth_for_monitoring_enabled = true` | `terraform validate` succeeds with the pinned provider, and current AzureRM docs list this optional setting. |
| Alerts | Node Not Ready, failed/CrashLoop pod, frequent restart rules | Each uses a 5-minute evaluation over 15 minutes; actual tables, delivery, and alert firing remain unverified. |

`terraform providers schema` cannot run until a real AzureRM backend is initialized because Terraform requires backend initialization for that subcommand. The pinned-provider configuration itself validates successfully, which verifies the configured AKS argument syntactically.

## CI/CD, Helm, and Argo CD Audit

| Area | Verified current state | Result / follow-up |
| --- | --- | --- |
| Workflow | Display name is **Build, Push and Update GitOps** | Triggered by application/workflow changes on `main`; `[skip ci]` prevents its own promotion commit from looping. |
| Azure auth | `azure/login@v2` accepts only client, tenant, and subscription IDs | OIDC-compatible; no client secret or `AZURE_CREDENTIALS` appears in tracked source. Entra federation is not configured yet. |
| Permissions | `id-token: write`, `contents: write` | Sufficient for OIDC and its GitOps commit; repo has no configured secrets/variables yet. |
| Artifact delivery | `GITHUB_SHA::7` tags `ACR_LOGIN_SERVER/IMAGE_NAME` | Immutable promotion pattern is correct; live ACR validation remains pending. |
| Desired state | Workflow deterministically updates exactly one `image.tag` line | `values.yaml` is the image source of truth. |
| Helm | Chart/application/deployment/service all use `azure-webapp` | Lint/template pass. The ACR repository is a non-deployable bootstrap placeholder until Terraform outputs the real login server. |
| Argo CD | Points to `devSatym/azure-aks-gitops-observability`, `helm/azure-webapp`, `main` | No Helm image overrides remain; cluster installation/sync is pending. |

## Application, Documentation, and Evidence Audit

- `app/index.html` now accurately presents the requested lightweight AKS GitOps/observability project.
- `README.md` and `docs/phases/` are inherited material and are not yet evidence-backed: they call this a platform, imply live validation, describe direct raw-manifest/Helm deployment, and embed inherited screenshots as evidence. They must be rewritten only after cloud validation.
- Existing `docs/screenshots/*.png` are inherited assets. They must not be represented as evidence from this Azure subscription; a fresh checklist and owner-captured evidence are pending.
- `docs/architecture/architecture-diagram.png` is inherited and describes an earlier direct GitHub Actions → Helm flow. The final README must use the verified Mermaid architecture instead of this asset.
- `docs/codex/` is the only current source of operational truth until the final README rewrite.

## Ownership, Stale Values, and Security Search

- No active source contains `rambabu`, `ram-webapp`, `ram-aks-web`, `acraksdemo`, `sttfstatram`, `rg-terraform-state`, `latest`, `client_secret`, `AZURE_CREDENTIALS`, or raw-manifest deployment commands.
- Historical strings occur only in the prior audit history and inherited documentation, which will be rewritten rather than treated as active configuration.
- The current remote owner is `devSatym`; its matching Terraform `Owner` tag is project-specific rather than an upstream coupling. It is retained as-is to avoid unnecessary resource naming/tag changes.
- `.gitignore` protects `.terraform/`, state, plans, `terraform.tfvars`, `backend.hcl`, local keys, environments, and kubeconfig. No state, backend configuration, credential, token, or generated Grafana password is tracked.

## External Environment Audit (Read-only)

- Azure CLI 2.89.1 is installed and authenticated to one enabled/default subscription. The subscription was inspected but never switched.
- A pre-existing `devops-rg` resource group is present in Central India; it contains no AKS, ACR, storage account, or Log Analytics workspace. It will not be repurposed without an explicit design decision.
- GitHub CLI is authenticated as the fork owner with repository administration permission. The public repository's default branch is `main`, has no branch protection, and has no configured Actions secrets or variables.
- Terraform 1.15.8, Helm 3.21.2, kubectl 1.34.1, and Docker 29.4.0 are installed.

## Files That Should Change Next

- Local ignored `backend.hcl` and `terraform.tfvars` after an alert-recipient decision.
- Helm `image.repository` after Terraform produces the actual ACR login server.
- Live tracking/validation documentation after each observed cloud result.
- Final evidence, README, phase guides, resume, interview guide, and cleanup guide only after their prerequisites are actually validated.

## Files That Should Remain Functionally Unchanged

- Terraform module topology, ACR admin-disabled setting, kubelet `AcrPull` assignment, simple nginx Dockerfile, and intentionally limited scope.
- The active Helm + Argo CD model must remain the sole application deployment model.
- No license was found; none will be added on the upstream author's behalf.

## Audit Conclusion

The local repository is correctly migrated through the source-cleanup phases and passes local structural checks. The remaining work is external, evidence-driven implementation: bootstrap an owner-controlled state backend, provision Azure, configure OIDC, perform the real GitOps/monitoring tests, and then replace inherited documentation with observed results. The immediate missing input is the Action Group email recipient; no Azure resource has been created or changed by this current execution.
