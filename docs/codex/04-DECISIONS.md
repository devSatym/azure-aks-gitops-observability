# Design Decisions

## ADR-001 — CI updates Git; Argo CD deploys

**Status:** accepted.
**Context:** the original workflow authenticated to Azure, built and pushed an image, then retrieved AKS credentials without performing a deployment. Argo CD was already present as a desired-state controller.
**Decision:** GitHub Actions owns build, immutable ACR publish, and a narrowly scoped Helm `image.tag` commit. Argo CD owns render, deploy, prune, and reconciliation.
**Consequences:** CI does not need routine Kubernetes administration; rollout failures are visible in Argo CD and rollback is a Git change to a prior SHA.

## ADR-002 — Git SHA image tags, never `latest`

**Status:** accepted.
**Context:** mutable tags weaken traceability and rollback. The existing workflow already derived the first seven characters of `GITHUB_SHA`.
**Decision:** retain seven-character Git SHA image tags and record the deployed tag in Helm values.
**Consequences:** each intended deployment is auditable from source commit to ACR artifact to GitOps commit. A user must select a known-good SHA for rollback.

## ADR-003 — Helm `values.yaml` is the sole image source

**Status:** accepted.
**Context:** Argo Application parameters override values with an obsolete upstream ACR/tag, so modifying values cannot change the deployed image.
**Decision:** remove Argo image parameter overrides; CI changes only `image.tag` in chart values.
**Consequences:** desired state has one source and Argo sees each promotion as a standard Git revision.

## ADR-004 — Local AzureRM backend configuration

**Status:** accepted.
**Context:** committed backend details target someone else's state resource group and storage account.
**Decision:** commit an empty AzureRM backend and `backend.hcl.example`; ignore the owner-specific `backend.hcl`. The example uses Microsoft Entra ID / Azure CLI authentication (`use_azuread_auth` and `use_cli`) rather than a storage access key.
**Consequences:** every user supplies their own storage coordinates with `terraform init -backend-config=backend.hcl` and needs `Storage Blob Data Contributor` on the state container; no storage key or backend name enters Git.

## ADR-005 — Passwordless GitHub OIDC with ACR-scoped RBAC

**Status:** accepted.
**Context:** CI needs to push images, not administer AKS.
**Decision:** use a main-branch GitHub federated credential and grant `AcrPush` at the project ACR scope. Do not introduce an Azure client secret or enable ACR admin credentials.
**Consequences:** short-lived credentials and least privilege; Entra/GitHub configuration is a required external setup step.

## ADR-006 — Two complementary monitoring paths

**Status:** accepted.
**Context:** Azure Monitor/Container Insights serves Azure-native inventory, logs, KQL alerting, and Action Groups; Prometheus/Grafana serves Kubernetes metrics and dashboards.
**Decision:** retain both without adding Loki, Tempo, OpenTelemetry, or custom dashboards.
**Consequences:** scope remains focused while telemetry purpose is clear.

## ADR-007 — Retire raw manifests

**Status:** accepted pending Helm lint/render.
**Context:** unreferenced raw manifests duplicate the Deployment/Service and include stale ACR and `latest` values.
**Decision:** delete `k8s/` after local chart equivalence validates, rather than preserve a competing deployment path.
**Consequences:** the README and operational guidance present exactly one active application deployment model: Helm controlled by Argo CD.

## ADR-008 — Keep scope intentionally narrow

**Status:** accepted.
**Decision:** do not add HPA, Ingress, TLS, service mesh, private networking, Key Vault, external secrets, policy, extra environments, DevSecOps scanners, or custom application instrumentation.
**Consequences:** the project demonstrates the requested DevOps flow rather than broadening into a platform project.

## ADR-009 — Container Insights uses managed identity authentication

**Status:** accepted.
**Context:** the current AKS module uses `oms_agent`. Terraform initialization locked AzureRM to 4.81.0. HashiCorp's resource documentation for that version documents `msi_auth_for_monitoring_enabled` in the `oms_agent` block.
**Decision:** set `msi_auth_for_monitoring_enabled = true` alongside the existing Log Analytics workspace ID.
**Consequences:** Container Insights monitoring is configured to use managed-identity authentication; apply-time behavior remains to be validated in the target subscription.
