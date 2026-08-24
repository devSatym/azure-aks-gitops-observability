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

**Status:** accepted and implemented.
**Context:** committed backend details target someone else's state resource group and storage account.
**Decision:** commit an empty AzureRM backend and `backend.hcl.example`; ignore the owner-specific `backend.hcl`. The example uses Microsoft Entra ID / Azure CLI authentication (`use_azuread_auth` and `use_cli`) rather than a storage access key.
**Consequences:** the active environment uses its ignored `backend.hcl` with the dedicated `rg-aksops-dev-tfstate` / `staksopsdevtf20260824` / `tfstate` backend. The Terraform operator has `Storage Blob Data Contributor`; shared-key access is disabled. No storage key or backend name enters Git.

## ADR-005 — Passwordless GitHub OIDC with ACR-scoped RBAC

**Status:** accepted.
**Context:** CI needs to push images, not administer AKS.
**Decision:** use a main-branch GitHub federated credential and grant `AcrPush` at the project ACR scope. Do not introduce an Azure client secret or enable ACR admin credentials.
**Consequences:** short-lived credentials and least privilege; Entra/GitHub configuration is a required external setup step.

## ADR-006 — Superseded v1 monitoring topology

**Status:** superseded by ADR-016 and ADR-017.
**Context:** the v1 implementation used Azure Monitor/Container Insights for
platform logs and alerts plus an in-cluster Prometheus/Grafana stack for
metrics.
**Decision:** retain Container Insights and its KQL alert path, replace the
self-hosted metrics stack with Azure Monitor managed Prometheus, and add
native OTLP ingestion for application telemetry. Do not add Loki, Tempo, or
custom dashboards.
**Consequences:** the v1 self-hosted stack remains historical validation
evidence only. The live three-path design and its capacity constraints are
documented in ADR-016 and ADR-017.

## ADR-007 — Retire raw manifests

**Status:** accepted and implemented locally.
**Context:** unreferenced raw manifests duplicate the Deployment/Service and include stale ACR and `latest` values.
**Decision:** delete `k8s/` after local chart equivalence validates, rather than preserve a competing deployment path.
**Consequences:** `k8s/` was removed after Helm lint/template passed. The final README and operational guidance must present exactly one active application deployment model: Helm controlled by Argo CD.

## ADR-008 — Keep scope intentionally narrow

**Status:** accepted.
**Decision:** do not add HPA, Ingress, TLS, service mesh, private networking, Key Vault, external secrets, policy, extra environments, DevSecOps scanners, or custom application instrumentation.
**Consequences:** the project demonstrates the requested DevOps flow rather than broadening into a platform project.

## ADR-009 — Container Insights uses managed identity authentication

**Status:** accepted.
**Context:** the current AKS module uses `oms_agent`. Terraform initialization locked AzureRM to 4.81.0. HashiCorp's resource documentation for that version documents `msi_auth_for_monitoring_enabled` in the `oms_agent` block.
**Decision:** set `msi_auth_for_monitoring_enabled = true` alongside the existing Log Analytics workspace ID.
**Consequences:** Container Insights monitoring is configured to use managed-identity authentication; apply-time behavior remains to be validated in the target subscription.

## ADR-010 — AKS control-plane identity receives subnet-scoped network access

**Status:** accepted.
**Context:** the AKS cluster uses Azure CNI with a Terraform-created custom subnet. Current AKS guidance requires the cluster identity to have at least Network Contributor on that subnet. A system-assigned identity cannot receive that role until after the cluster exists.
**Decision:** keep the existing system-assigned control-plane identity and create a Terraform-managed `Network Contributor` assignment at the AKS subnet scope immediately after cluster creation. Keep the separate kubelet `AcrPull` assignment at the ACR scope. Both managed-identity assignments use `skip_service_principal_aad_check` to avoid directory-replication checks during apply.
**Consequences:** the design remains minimal and least-privilege. RBAC propagation can take time after apply, so cluster/load-balancer verification must wait for effective permissions rather than adding broad roles or changing to a service principal.

## ADR-011 — Alerts use current Container Insights status semantics

**Status:** accepted.
**Context:** current `KubePodInventory` uses `ContainerStatus` for a container state such as `waiting` and `ContainerStatusReason` for `CrashLoopBackOff` or `Error`. Its restart counter is cumulative.
**Decision:** detect crash loops through `ContainerStatus == "waiting"` and `ContainerStatusReason`, retain failed pods as a separate condition, and alert on a restart-count delta within the rule's 15-minute window rather than an all-time maximum.
**Consequences:** a disposable failed pod can be used for a controlled alert test, and a historical restart count does not leave an alert perpetually true. Actual telemetry/table behavior still requires live validation.

## ADR-012 — Do not apply the Application before the first real image exists

**Status:** accepted.
**Context:** the chart's bootstrap image is intentionally nonexistent and CI publishes only SHA tags. Applying the Argo Application beforehand would produce `ImagePullBackOff` and fail a first-health check for a known reason.
**Decision:** install Argo CD first, then produce and commit the first real ACR SHA tag through CI, then apply the Application manifest.
**Consequences:** first synchronization begins from a deployable desired state while preserving the CI → Git → Argo ownership model.

## ADR-013 — Isolate this project's kubectl access

**Status:** accepted.
**Context:** the current default kubeconfig points to an unreachable external GKE production-named context, not this Azure project.
**Decision:** after AKS provisioning, obtain credentials into a dedicated project kubeconfig file and invoke kubectl/Helm with that explicit configuration. Do not overwrite or use the existing default context.
**Consequences:** no project validation command can accidentally target an unrelated cluster. The dedicated local kubeconfig remains untracked and must never be committed.

## ADR-014 — Derive the GitHub OIDC subject instead of hard-coding a legacy name-only value

**Status:** accepted and implemented.
**Context:** GitHub's OIDC customization endpoint for this repository returns an immutable subject prefix containing repository-owner and repository identifiers. A legacy name-only `repo:owner/repo:ref:...` federated credential would not match its emitted token.
**Decision:** obtain the current prefix from the repository's OIDC customization API at setup time and append the narrowly scoped main-branch reference. Create one Entra federated credential from that exact value.
**Consequences:** OIDC setup remains compatible with GitHub's current subject model without weakening the federation to another branch, environment, or repository.

## ADR-015 — Manage the Container Insights DCR and association with Terraform

**Status:** accepted and implemented; live pod/node ingestion, KQL validation, a controlled fired alert, and recipient-confirmed email delivery pass.
**Context:** the AKS `oms_agent` block enabled managed-identity monitoring and deployed healthy `ama-logs` pods, but Azure created neither the Container Insights Data Collection Rule nor its association. The agent reported missing DCR JSON and no pod/node records reached Log Analytics. Current Microsoft AKS MSI-onboarding Terraform guidance declares both resources in addition to the AKS add-on.
**Decision:** retain managed-identity authentication and add a Terraform-managed Container Insights DCR with the standard pod/node/container streams plus a DCR association targeted at this AKS cluster. Do not revert to workspace keys, enable ACR admin credentials, or add unrelated monitoring products.
**Consequences:** the monitoring topology becomes declarative and reviewable. The correction adds no compute resource; once active, its intentional full stream set incurs normal Log Analytics ingestion cost and must be validated before controlled alert testing.

## ADR-016 — Send vendor-neutral application telemetry through native Azure OTLP

**Status:** accepted and live validated.
**Context:** the official OpenTelemetry Demo is already instrumented and must
remain vendor-neutral. Application Insights needs an Azure-native ingestion
path without committing a connection string or adding Azure SDK code to every
demo service.
**Decision:** deploy the OpenTelemetry Collector Contrib distribution as a
gateway. It authenticates by AKS workload identity to a user-assigned managed
identity with `Monitoring Metrics Publisher` scoped to a Terraform-managed
native OTLP DCR. The DCR/DCE route traces and logs to the existing Log
Analytics workspace and metrics to the Azure Monitor workspace, while an
Application Insights reference provides Azure application context. Terraform
owns only the namespace, annotated collector ServiceAccount, and non-secret
endpoint ConfigMap; Argo CD owns the charted collector Deployment.
**Consequences:** no instrumentation key or connection string is stored in Git.
The DCR's detailed `Microsoft-OTel-*` data-source streams are distinct from
the case-sensitive aggregate `Microsoft-OTLP-Traces` and
`Microsoft-OTLP-Logs` request URL streams. A desired-state revision annotation
rolls the collector whenever Terraform changes its external endpoint ConfigMap.

## ADR-017 — Use managed Prometheus and fit the demo to the quota-constrained cluster

**Status:** accepted and live validated.
**Context:** the Central India subscription has only four available DSv5 vCPUs,
which supports the existing two `Standard_D2s_v5` nodes but rejects a temporary
third node. The two-node cluster permits 60 pods. After the managed metrics
add-on was enabled, the full 22-pod upstream demo plus the seven-pod
`kube-prometheus-stack` would not fit.
**Decision:** validate Azure Monitor managed Prometheus first, retire only the
`kube-prometheus-stack` Helm release while retaining Prometheus Operator CRDs,
and disable five ancillary, dependency-free demo components in the wrapper.
The retained 17-pod demo preserves the storefront, checkout, messaging, load
generator, Collector, and multi-language service paths.
**Consequences:** the live cluster runs at 59/60 pods, so no self-hosted stack
or extra demo replicas may be added. Restore the complete upstream component
set only after a quota/capacity increase.
