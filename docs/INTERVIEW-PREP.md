# Interview Preparation — Azure AKS GitOps CI/CD & Observability

This guide is grounded in the repository and the recorded validation evidence. It does not treat configuration as runtime proof where that proof has not been collected. The disposable `ci-alert-test` pod was observed in KQL, produced a real scheduled-query alert, and the configured recipient confirmed email receipt.

## 1. What problem does this project solve?

**Short interview answer:** It provides a small, auditable path from an application source change to an immutable container image, a Git-recorded Kubernetes desired state, an AKS deployment, and observable operational signals.

**Detailed explanation:** The project separates infrastructure provisioning, image publishing, deployment reconciliation, and monitoring. Terraform creates the Azure foundation; GitHub Actions builds and publishes an immutable image and changes only the Helm image tag in Git; Argo CD reconciles that Git state into AKS; Azure Monitor and Prometheus/Grafana provide complementary observability. The aim is a demonstrable delivery pattern, not a claim of production-scale availability or performance.

**Where it exists in this repo:** `main.tf`, `.github/workflows/deploy-aks.yml`, `argocd/azure-webapp-application.yaml`, `helm/azure-webapp/`, and `modules/monitoring`, `modules/container_insights`, and `modules/alerts`.

**How we validated it:** A source change produced the SHA-tagged image `9d37a77`; the CI run updated only Helm `image.tag`; Argo CD synchronized that desired state; two application pods served the delivery marker. The evidence is recorded in `docs/codex/03-VALIDATION.md`.

## 2. What does Terraform provision?

**Short interview answer:** Terraform provisions the Azure resource group, network, AKS cluster, ACR, Log Analytics workspace, Azure Monitor alerting, required role assignments, and the Container Insights data-collection configuration.

**Detailed explanation:** The reviewed base apply created 13 resources: a project resource group, VNet and AKS subnet, Basic ACR, Log Analytics workspace, AKS cluster, Action Group, three scheduled-query alert rules, ACR pull and subnet network role assignments, and the deterministic name suffix. A later focused apply added the Container Insights DCR and its AKS association. The remote state backend was bootstrapped separately so Terraform can safely manage this configuration.

**Where it exists in this repo:** `main.tf` composes the modules; the implementation is under `modules/resource_group`, `modules/network`, `modules/acr`, `modules/aks`, `modules/monitoring`, `modules/container_insights`, and `modules/alerts`.

**How we validated it:** `terraform fmt -check`, `terraform validate`, a reviewed plan with 13 adds and no changes or destroys, the successful base apply, and the later DCR/DCRA apply with two additions were recorded in `docs/codex/03-VALIDATION.md`.

## 3. How is Terraform state managed?

**Short interview answer:** State is stored remotely in a private Azure Blob container, and local backend configuration is ignored by Git.

**Detailed explanation:** The AzureRM backend is declared without hard-coded environment values. An ignored local `backend.hcl` supplies the storage location and uses the authenticated Azure CLI/Microsoft Entra session rather than a storage-account key. This keeps state and environment-specific backend details out of source control while giving the team a shared source of truth.

**Where it exists in this repo:** `providers.tf` declares `backend "azurerm" {}`; `backend.hcl.example` documents the safe shape of the ignored local configuration; `.gitignore` excludes the real backend file and state artifacts.

**How we validated it:** Remote initialization using Entra/Azure CLI authentication succeeded, and private container access plus the Terraform operator's Blob Data Contributor access were checked without recording any credentials.

## 4. Why Azure Storage remote state?

**Short interview answer:** Azure Storage provides durable, centralized state close to the Azure resources, with Azure RBAC-based access instead of a local state file.

**Detailed explanation:** A remote backend avoids divergent local copies of the infrastructure state and lets Terraform coordinate changes through the backend. The selected design uses a private blob container, Entra-based access, and no shared storage key in the repository. It is a practical fit for an Azure-only project and makes state ownership and retention an explicit operational concern.

**Where it exists in this repo:** `providers.tf`, `backend.hcl.example`, `.gitignore`, and the backend notes in `docs/codex/02-PROJECT-STATUS.md`.

**How we validated it:** `terraform init -reconfigure -backend-config=backend.hcl` completed successfully against the private backend, and the state access path was inspected through Azure RBAC rather than a storage key.

## 5. What is AKS?

**Short interview answer:** AKS is Azure Kubernetes Service: Azure manages the Kubernetes control plane while the project configures and operates its worker-node pool and workloads.

**Detailed explanation:** In this project, AKS runs the application and the in-cluster monitoring components. It uses Azure CNI networking, a Standard Load Balancer, a system-assigned control-plane identity, and a two-node system pool. The Kubernetes API is accessed only through a dedicated project kubeconfig so an unrelated default context cannot be used accidentally.

**Where it exists in this repo:** `modules/aks/main.tf`, the subnet and role assignment in `main.tf`, and the workload definition in `helm/azure-webapp/`.

**How we validated it:** Both AKS nodes were Ready, system and `ama-logs` pods were Running, and all project Kubernetes checks used the dedicated kubeconfig. The application subsequently rolled out as two Ready replicas.

## 6. What is ACR?

**Short interview answer:** Azure Container Registry is the private Azure registry that stores the application images used by AKS.

**Detailed explanation:** The CI workflow builds the `app/` Docker image and pushes a Git-SHA tag to the project ACR. Helm values then reference that registry and tag, so the workload pulls the same immutable artifact that CI published. This keeps the container artifact inside the Azure environment and makes image provenance easy to inspect.

**Where it exists in this repo:** `modules/acr/`, `helm/azure-webapp/values.yaml`, and `.github/workflows/deploy-aks.yml`.

**How we validated it:** The registry was provisioned with Basic SKU and admin access disabled; CI successfully pushed `azure-webapp:9d37a77`, and the deployed AKS workload used that image tag.

## 7. How does AKS authenticate to ACR?

**Short interview answer:** The AKS kubelet managed identity receives the `AcrPull` role scoped only to the project ACR.

**Detailed explanation:** AKS uses its kubelet identity to request images. Terraform assigns that identity Azure RBAC pull permission on the registry, so the cluster does not need an image-pull secret or ACR admin credentials. The scope is intentionally the single project registry rather than the whole subscription.

**Where it exists in this repo:** The `azurerm_role_assignment.aks_acr_pull` resource in `main.tf`, plus the kubelet identity output in `modules/aks/outputs.tf`.

**How we validated it:** Terraform created the scoped assignment, the ACR image exists, and the Argo-managed Deployment reached two Ready replicas using the project ACR image.

## 8. Why is ACR admin authentication disabled?

**Short interview answer:** Disabling it avoids a shared registry username and password; access is instead granted through scoped Azure identities and RBAC.

**Detailed explanation:** The registry's admin account is a broad, static credential path. This project uses the AKS kubelet identity with `AcrPull` for runtime pulls and the GitHub OIDC service principal with `AcrPush` for CI publishing. That reduces secret handling and makes the permission boundaries explicit and inspectable.

**Where it exists in this repo:** `modules/acr/main.tf`, `main.tf` for the AKS pull assignment, and `.github/workflows/deploy-aks.yml` for the CI registry login and push.

**How we validated it:** Azure inspection confirmed that ACR admin access is disabled, while the OIDC-based CI push and AKS workload pull both succeeded.

## 9. How does GitHub OIDC work?

**Short interview answer:** GitHub Actions requests a short-lived signed identity token, and Microsoft Entra exchanges it for Azure access only when it matches the configured repository and branch federation rule.

**Detailed explanation:** The workflow has `id-token: write` and uses `azure/login@v2`. A dedicated Entra application has a federated credential derived from the repository's current GitHub OIDC subject prefix and narrowed to the `main` branch. Azure trusts that token instead of a client secret, then issues a short-lived access token whose Azure RBAC is limited to the required ACR action.

**Where it exists in this repo:** `.github/workflows/deploy-aks.yml` contains the OIDC login; the federation setup and its reasoning are recorded in `docs/codex/04-DECISIONS.md` and `docs/codex/02-PROJECT-STATUS.md`.

**How we validated it:** The first real GitHub Actions run completed Azure login with OIDC and then pushed the SHA-tagged image. The federation and its ACR-scoped role were also inspected through Azure and GitHub configuration APIs without exposing values.

## 10. Why is OIDC better than a stored client secret?

**Short interview answer:** OIDC avoids storing a long-lived Azure client secret in GitHub and replaces it with short-lived, issuer-verified tokens.

**Detailed explanation:** A stored secret can leak, expire, be copied, or need manual rotation. With workload identity federation, Azure verifies the token issuer, audience, repository identity, and branch scope before issuing a token. It does not eliminate authorization design—the service principal still needs minimal Azure RBAC—but it removes the static credential from the CI secret set.

**Where it exists in this repo:** `.github/workflows/deploy-aks.yml` and the OIDC decision record in `docs/codex/04-DECISIONS.md`.

**How we validated it:** The repository configuration was checked for the expected Azure identifier secret names only, no client secret was created for the CI principal, and the real OIDC login succeeded in the first delivery run.

## 11. What Azure RBAC role does CI receive?

**Short interview answer:** CI receives `AcrPush`, scoped to the project ACR only.

**Detailed explanation:** The CI service principal needs to authenticate to Azure and publish the application image. It does not need subscription-wide Contributor, AKS administration, or a runtime pull role. GitHub's separate `contents: write` permission is used only to commit the desired Helm image tag back to the repository.

**Where it exists in this repo:** The workflow's intended registry actions are in `.github/workflows/deploy-aks.yml`; the inspected RBAC boundary is recorded in `docs/codex/02-PROJECT-STATUS.md` and `docs/codex/03-VALIDATION.md`.

**How we validated it:** Azure role-assignment inspection showed `AcrPush` at the ACR scope, and the actual OIDC workflow successfully built and pushed the immutable image without a broader Azure deployment role.

## 12. Why use SHA image tags?

**Short interview answer:** A Git SHA tag creates an immutable, traceable link between source, the registry artifact, the GitOps change, and the running workload.

**Detailed explanation:** The workflow derives the first seven characters of `GITHUB_SHA` and uses that value as the image tag. The tag is written into Helm values only after the image is pushed. This makes it possible to inspect what source revision was intended for a deployment and to choose a known-good image for a Git-based rollback.

**Where it exists in this repo:** The `Calculate immutable image tag`, build, push, and update steps are in `.github/workflows/deploy-aks.yml`; the selected tag is in `helm/azure-webapp/values.yaml`.

**How we validated it:** CI produced and pushed `9d37a77`; the following bot commit changed exactly the single `image.tag` field to that value, and Argo deployed the resulting desired state.

## 13. Why not `latest`?

**Short interview answer:** `latest` is mutable, so it cannot reliably say which source revision is running or be safely used as a rollback target.

**Detailed explanation:** A mutable tag can point to different image content at different times and can interact poorly with image caching and rollout diagnosis. A SHA tag preserves the source-to-artifact mapping. The project still needs an operator to retain and select a known-good tag for rollback, but it avoids the ambiguity of an overwritten tag.

**Where it exists in this repo:** `.github/workflows/deploy-aks.yml`, `helm/azure-webapp/values.yaml`, and ADR-002 in `docs/codex/04-DECISIONS.md`.

**How we validated it:** The deployed Helm value uses the observed SHA tag rather than `latest`, and the corresponding ACR tag and GitOps commit were inspected as one delivery lineage.

## 14. What does GitHub Actions own?

**Short interview answer:** GitHub Actions owns build and publication of the image plus the narrow Git desired-state update; it does not own deployment into AKS.

**Detailed explanation:** The workflow checks out source, authenticates through OIDC, validates required repository variables, calculates the SHA tag, builds and pushes the image, then uses a deterministic script to change exactly one `image.tag` line and commit it. The workflow has no `kubectl`, Helm upgrade, Argo sync, or AKS credentials step.

**Where it exists in this repo:** `.github/workflows/deploy-aks.yml`.

**How we validated it:** Source review confirmed the ownership boundary; the first successful run pushed the image and made the one-field bot commit. Git and GitHub Actions evidence showed no direct cluster deployment action.

## 15. Why doesn't CI directly deploy to AKS?

**Short interview answer:** Deployment is intentionally delegated to Argo CD so Git remains the desired-state source and the cluster has a continuous reconciler independent of the CI job.

**Detailed explanation:** A direct CI deployment would combine artifact publishing and cluster mutation in one job and make reconciliation dependent on that job running perfectly. Here CI promotes a built artifact by committing desired state, while Argo reads that state, renders Helm, applies it, reports health, and repairs drift. This also keeps CI's Azure RBAC limited to ACR publishing rather than routine Kubernetes administration.

**Where it exists in this repo:** `.github/workflows/deploy-aks.yml`, `argocd/azure-webapp-application.yaml`, and ADR-001 in `docs/codex/04-DECISIONS.md`.

**How we validated it:** The workflow was inspected for the absence of direct deployment commands, then the bot GitOps commit was observed separately from Argo's successful synchronization and workload rollout.

## 16. What does Argo CD own?

**Short interview answer:** Argo CD owns rendering and reconciling the Helm desired state into AKS, including automated sync, drift repair, and pruning within the Application scope.

**Detailed explanation:** The Application points at this repository's `main` branch and `helm/azure-webapp` path. Argo renders the chart and keeps the target namespace aligned with Git. It does not build images or edit the image tag; it consumes the desired state committed by CI or by an approved Git rollback.

**Where it exists in this repo:** `argocd/azure-webapp-application.yaml` and `helm/azure-webapp/`.

**How we validated it:** Argo CD core components were healthy, the Application reached `Synced` and `Healthy` at the bot promotion revision, and it restored a deliberate replica-count drift.

## 17. What is GitOps?

**Short interview answer:** GitOps is an operating model in which Git declares the desired system state and a controller continuously reconciles the live environment to that state.

**Detailed explanation:** In this implementation, the important desired-state datum is Helm's image tag. CI changes that field through a commit; Argo CD detects the commit and applies the chart. The Git history becomes the reviewable record of intended deployment changes, while Argo's status provides the observed reconciliation outcome.

**Where it exists in this repo:** `helm/azure-webapp/values.yaml`, `.github/workflows/deploy-aks.yml`, and `argocd/azure-webapp-application.yaml`.

**How we validated it:** The first CI run produced a separate bot commit for the image tag, Argo synchronized that commit, and the workload was healthy without CI directly calling Kubernetes deployment commands.

## 18. What does `selfHeal` do?

**Short interview answer:** `selfHeal` tells Argo CD to correct live drift so the cluster returns to the state declared in Git.

**Detailed explanation:** If an in-cluster change differs from the rendered Helm output, Argo marks the Application out of sync and reconciles it back. It is not a substitute for application health checks or safe change review; it is a guardrail that keeps the running resource specification aligned with Git.

**Where it exists in this repo:** `argocd/azure-webapp-application.yaml` under `spec.syncPolicy.automated.selfHeal`.

**How we validated it:** The Deployment was deliberately scaled from two to four replicas outside Git. Argo detected the drift and restored it to two replicas in 28 seconds, returning the Application to `Synced` and `Healthy`.

## 19. What does `prune` do?

**Short interview answer:** `prune` lets Argo CD remove resources that are no longer declared by the Application's desired state.

**Detailed explanation:** Without pruning, deleting a rendered object from Git can leave an orphaned live Kubernetes object behind. Enabling pruning keeps the resources owned by this Application aligned with the chart output. It should be used with clear ownership boundaries because deleting a manifest from Git can intentionally remove the corresponding live object.

**Where it exists in this repo:** `argocd/azure-webapp-application.yaml` under `spec.syncPolicy.automated.prune`.

**How we validated it:** The Application manifest and Argo's live configuration were inspected with `prune: true`. No destructive prune scenario was intentionally executed; this is configuration validation, not a live deletion test.

## 20. Why Helm?

**Short interview answer:** Helm templates the Kubernetes resources and makes the image, replica count, service type, ports, and resource settings explicit values rather than duplicated static manifests.

**Detailed explanation:** The project has one compact chart that renders the Deployment and LoadBalancer Service. Helm makes `image.tag` the single release input CI changes, while Argo renders the same chart from Git. It is deliberately modest: no hidden release automation or unrelated chart complexity is introduced.

**Where it exists in this repo:** `helm/azure-webapp/Chart.yaml`, `helm/azure-webapp/values.yaml`, and `helm/azure-webapp/templates/`.

**How we validated it:** Helm lint and template checks passed; the render contained one Service and one two-replica Deployment; Argo successfully deployed the chart from the repository path.

## 21. Helm vs raw Kubernetes manifests?

**Short interview answer:** Raw manifests are static YAML; Helm adds parameterized templates and a values interface. This project uses Helm to keep the image tag as one controlled desired-state field.

**Detailed explanation:** Either approach can be valid. Raw manifests are often straightforward for small, fixed resources, but they can duplicate values across files. Helm centralizes release settings and renders consistent objects. In this repository, legacy raw application manifests were removed so the Argo Application has one clear source: the Helm chart.

**Where it exists in this repo:** `helm/azure-webapp/` is the active workload source, and `argocd/azure-webapp-application.yaml` targets that path.

**How we validated it:** A repository audit confirmed that the active delivery path is Helm-only; Helm rendering passed and the Argo-managed Deployment and Service were observed live.

## 22. How does a new application version reach AKS?

**Short interview answer:** An application commit triggers CI, CI pushes a SHA-tagged image and commits that tag to Helm values, then Argo CD sees the Git change and reconciles the workload in AKS.

**Detailed explanation:** The sequence is: source change → GitHub Actions OIDC login → Docker build → ACR push under a SHA tag → deterministic `image.tag` update and bot commit → Argo CD synchronization → Kubernetes rollout. The image is pushed before the GitOps update, preventing Argo from trying to pull a tag that does not exist.

**Where it exists in this repo:** `app/`, `.github/workflows/deploy-aks.yml`, `helm/azure-webapp/values.yaml`, and `argocd/azure-webapp-application.yaml`.

**How we validated it:** The first source delivery `9d37a77` led to the pushed ACR image, bot commit `751d2c4`, Argo synchronization, a two-pod rollout, and the expected LoadBalancer response marker.

## 23. How would rollback work?

**Short interview answer:** Change `image.tag` in Git back to a known-good, retained SHA tag and let Argo CD reconcile the prior desired state.

**Detailed explanation:** Because the deployment is GitOps-driven, rollback is a reviewable Git change rather than an ad hoc cluster command. The target SHA must still exist in ACR, and the operator should verify Argo health and the rollout after the commit. Reverting the bot commit or making a new explicit rollback commit both preserve the audit trail.

**Where it exists in this repo:** `helm/azure-webapp/values.yaml`, the promotion workflow, `argocd/azure-webapp-application.yaml`, and ADR-002 in `docs/codex/04-DECISIONS.md`.

**How we validated it:** The immutable source-to-image-to-Helm lineage was proven for the first deployment. A production-style rollback has not been executed, so this is a validated rollback mechanism rather than a completed rollback test.

## 24. What if CI succeeds but Argo CD deployment fails?

**Short interview answer:** CI success means the artifact and desired-state commit succeeded; it does not mean the cluster rollout succeeded. Argo status and Kubernetes events become the next diagnostic signal.

**Detailed explanation:** The image can be present in ACR and the Git tag can be correct while the chart, image pull, scheduling, or readiness behavior prevents a healthy rollout. Operators should inspect the Argo Application health and sync details, then Kubernetes Deployment/Pod events, correct the Git configuration or application, or revert to a known-good SHA. The desired-state boundary makes the correction auditable and avoids pretending that a green CI job proves production health.

**Where it exists in this repo:** `.github/workflows/deploy-aks.yml` ends at the Git desired-state update; `argocd/azure-webapp-application.yaml` and `helm/azure-webapp/` define the subsequent reconciliation.

**How we validated it:** The normal success path was observed end to end, and Argo status was used during the deliberate drift test. An intentional Argo rollout failure was not injected, so the failure response is documented operational design rather than a completed fault test.

## 25. What if someone manually changes the Deployment?

**Short interview answer:** Argo CD detects the drift and, with `selfHeal` enabled, restores the Helm/Git-defined Deployment.

**Detailed explanation:** Manual edits create a difference between live state and the chart rendered from Git. Argo reports that as out of sync and reconciles the desired deployment. This prevents undocumented live edits from becoming the long-term source of truth; a legitimate change must be captured in Git.

**Where it exists in this repo:** `argocd/azure-webapp-application.yaml` and the replica declaration in `helm/azure-webapp/values.yaml`.

**How we validated it:** A controlled `kubectl scale` changed replicas from two to four. The Application became out of sync/progressing, then Argo restored two replicas in 28 seconds without any Git change.

## 26. What is Container Insights?

**Short interview answer:** Container Insights is Azure Monitor's AKS monitoring integration for Kubernetes inventory, logs, events, and selected metrics sent to Log Analytics.

**Detailed explanation:** The AKS OMS monitoring add-on runs the collection agents using managed-identity authentication. A Data Collection Rule defines the streams sent to the Log Analytics workspace, and a DCR association connects that rule to AKS. The project explicitly manages both because healthy agents alone did not create the needed telemetry configuration.

**Where it exists in this repo:** `modules/aks/main.tf` enables the managed-identity monitoring add-on; `modules/container_insights/main.tf` defines the DCR streams and `ContainerInsightsExtension` association.

**How we validated it:** The initial diagnosis found no DCR/DCRA and no inventory data. Terraform then added the DCR and association; the disposable failed pod has subsequently been observed in `KubePodInventory` through KQL. Scheduled alert firing remains a separate in-progress check.

## 27. What is Log Analytics?

**Short interview answer:** Log Analytics is the Azure workspace that stores and queries collected monitoring data for this project.

**Detailed explanation:** The workspace receives the Container Insights streams defined by the DCR and is the scope for the scheduled KQL alert rules. It has a configured 30-day retention period. Log Analytics provides the Azure-native query plane for pod and node inventory, container logs, and alert conditions; it is distinct from the in-cluster Prometheus metrics store.

**Where it exists in this repo:** `modules/monitoring/main.tf`, `modules/container_insights/main.tf`, and `modules/alerts/main.tf`.

**How we validated it:** Terraform provisioned the workspace and Azure inspection verified that the alert rules target it. KQL was used to observe the `ci-alert-test` failed-pod inventory record after Container Insights configuration propagated.

## 28. What is KQL?

**Short interview answer:** KQL, or Kusto Query Language, is the query language used to explore Log Analytics data and define this project's Azure Monitor alert conditions.

**Detailed explanation:** KQL filters data by time, selects relevant status fields, groups values, and returns records that alert rules can count. Here it identifies non-Ready nodes, failed or CrashLoopBackOff pods, and significant restart-count deltas in a 15-minute window. Query semantics matter: the project uses current inventory fields rather than relying on a guessed older schema.

**Where it exists in this repo:** The three alert queries are in `modules/alerts/main.tf`; validation and schema decisions are recorded in `docs/codex/03-VALIDATION.md` and `docs/codex/04-DECISIONS.md`.

**How we validated it:** Initial empty results exposed the missing DCR/DCRA. After the correction, a KQL query observed the controlled `ci-alert-test` failure in `KubePodInventory`; alert-rule evaluation and notification confirmation are still underway.

## 29. How do Azure Monitor alerts work?

**Short interview answer:** Azure Monitor runs each scheduled KQL query on its configured workspace and, when the result count crosses the rule threshold, sends the alert to its attached Action Group.

**Detailed explanation:** This project has three enabled scheduled-query rules: node not ready, failed/CrashLoop pod, and frequent pod restarts. Each evaluates every five minutes over a 15-minute window and triggers when its count is greater than zero. The query result is the signal; the Action Group is the notification routing mechanism. The restart query uses a time-window delta so a historical count does not cause a permanently true alert.

**Where it exists in this repo:** `modules/alerts/main.tf` and its outputs/inputs under `modules/alerts/`.

**How we validated it:** Azure inspection confirmed all three enabled rules, their scopes, frequency, window, criteria, and Action Group attachment. The failed-pod data is visible through KQL; the scheduled-rule firing and recipient delivery are not yet claimed as complete.

## 30. What is an Action Group?

**Short interview answer:** An Action Group is Azure Monitor's reusable notification and action-routing object attached to one or more alert rules.

**Detailed explanation:** Rather than embedding notification logic separately in each rule, the rules reference one Action Group. This project configures a common-alert-schema email receiver through an input kept out of tracked source. The group could later be extended with approved operational actions, but this implementation intentionally keeps the scope to the configured notification receiver.

**Where it exists in this repo:** `modules/alerts/main.tf` declares `azurerm_monitor_action_group.this`; the recipient input is declared in `modules/alerts/variables.tf` and provided only through ignored local configuration.

**How we validated it:** Azure inspection confirmed one enabled Action Group with one receiver and confirmed that all three scheduled-query rules reference it. After the controlled fired alert, the configured recipient confirmed email receipt; the address itself remains undisclosed.

## 31. What controlled failure was tested?

**Short interview answer:** A disposable `ci-alert-test` pod with `restartPolicy: Never` was intentionally failed, observed in `KubePodInventory` using KQL, and produced real Azure Monitor fired-alert instances.

**Detailed explanation:** The test was designed to exercise the deployed failed-pod condition safely without disturbing the two-replica application. The pod is a temporary live test artifact, not a permanent application manifest. Its KQL observation proved that the telemetry path records the relevant failure state after the DCR/DCRA correction. Azure Alert Management then recorded four real Sev2 fired instances for the failed-pod rule. The pod was deleted after collection, and the configured recipient confirmed the Action Group email delivery without the address being recorded.

**Where it exists in this repo:** The alert condition is in `modules/alerts/main.tf`; the temporary pod itself is intentionally not tracked as a deployment manifest. The ongoing runtime evidence is recorded in `docs/codex/03-VALIDATION.md` and `docs/codex/02-PROJECT-STATUS.md`.

**How we validated it:** The disposable pod was created with a non-restarting failure behavior and appeared as a failed record in `KubePodInventory`. Azure Alert Management reported the first fired instance at `2026-08-24T03:28:47.4605953Z` and four fired instances total; the temporary pod was then deleted. The configured recipient subsequently confirmed email receipt.

## 32. Azure Monitor vs Prometheus?

**Short interview answer:** Azure Monitor/Log Analytics provides Azure-native inventory, logs, KQL, and Azure alerting; Prometheus provides in-cluster metrics scraping, and Grafana visualizes those metrics.

**Detailed explanation:** These tools answer related but different questions. Container Insights sends inventory and log streams to Log Analytics under Azure's DCR model, where KQL scheduled queries drive Action Groups. `kube-prometheus-stack` collects Kubernetes and workload metrics locally, and Grafana exposes supplied dashboards. The project deliberately uses both rather than presenting one as a replacement for the other.

**Where it exists in this repo:** Azure monitoring is implemented in `modules/monitoring`, `modules/container_insights`, and `modules/alerts`; the Prometheus/Grafana deployment is documented in `docs/codex/01-IMPLEMENTATION-PLAN.md` and validation evidence.

**How we validated it:** Container Insights configuration and a KQL failed-pod record were observed. Prometheus was healthy with 18/18 active targets and the application replica metric; Grafana reported healthy storage and 29 supplied dashboards.

## 33. What does Grafana show?

**Short interview answer:** Grafana presents the Prometheus-backed Kubernetes dashboards for cluster, node, namespace, pod, and workload visibility.

**Detailed explanation:** The installed `kube-prometheus-stack` supplies Grafana and Kubernetes-oriented dashboards. Grafana is useful for visual trend and status exploration, while Prometheus remains the query and metrics store beneath it. No custom dashboards, ingress exposure, or password values are stored in this repository.

**Where it exists in this repo:** The monitoring-stack deployment and its validation are documented in `docs/codex/01-IMPLEMENTATION-PLAN.md`, `docs/codex/02-PROJECT-STATUS.md`, and `docs/codex/03-VALIDATION.md`.

**How we validated it:** A local-only port-forward/API check confirmed Grafana database health and 29 supplied dashboards. Prometheus returned the two available `azure-webapp` replicas and all 18 active targets were up; fresh owner-captured dashboard screenshots remain a separate documentation task.

## 34. What are the project's limitations?

**Short interview answer:** It is a focused demonstration environment, not a full production landing zone; several production controls and a portion of the alert proof remain intentionally incomplete.

**Detailed explanation:** The project uses a small two-node AKS cluster, Basic ACR, a public LoadBalancer service, Argo's default project, and a simple nginx application. It does not currently implement HPA, ingress/TLS, Key Vault integration, private endpoints, network policies, production SLOs, image signing/scanning, branch protection, multi-zone resilience, or custom Grafana dashboards. The Azure Monitor failed-pod signal is visible in KQL, a scheduled-rule alert fired, and the recipient confirmed delivery. Fresh owner screenshots remain outstanding.

**Where it exists in this repo:** The current deployment scope is visible in `modules/`, `helm/azure-webapp/`, and `argocd/azure-webapp-application.yaml`; validation status and known gaps are maintained in `docs/codex/02-PROJECT-STATUS.md` and `docs/codex/03-VALIDATION.md`.

**How we validated it:** The limitations follow directly from the checked-in configuration and the validation matrix. They are stated as scope boundaries, not inferred claims about reliability, cost savings, or availability.

## 35. What would be improved for real production?

**Short interview answer:** I would add environment governance, private and highly available networking, workload security, autoscaling, stronger supply-chain controls, and an operations model tied to agreed SLOs.

**Detailed explanation:** Likely next steps include protected branches and pull-request review, separate environments and state boundaries, image scanning/signing and retention policy, private AKS/ACR connectivity, ingress with managed TLS, network policies, workload identity and Key Vault integration, resource quotas, PodDisruptionBudgets, HPA/cluster autoscaler, multi-zone sizing, backups/disaster recovery, and runbooks with tested alerts. Each should be chosen against concrete application requirements, threat model, budget, recovery objectives, and traffic profile rather than added indiscriminately.

**Where it exists in this repo:** The deliberate exclusions and their rationale are described in `docs/codex/01-IMPLEMENTATION-PLAN.md`; the current minimal scope is visible in the Terraform, Helm, and Argo source.

**How we validated it:** This is a future-state recommendation, not a completed feature list. The existing configuration was audited to distinguish implemented controls from proposed production improvements.

## 36. Why were HPA/Ingress/Key Vault/etc. intentionally excluded?

**Short interview answer:** They are important production capabilities, but they were excluded to keep this project focused on one verifiable CI-to-GitOps and observability path without inventing application requirements.

**Detailed explanation:** HPA needs meaningful metrics and scaling objectives; ingress/TLS needs DNS, certificate, routing, and exposure decisions; Key Vault needs a defined secret-consumption and workload-identity design. Adding them without those requirements would increase cost, security surface, and operational complexity while weakening the clarity of this learning and validation project. Their exclusion is explicit, not an assertion that they are unnecessary in production.

**Where it exists in this repo:** The intentionally small Helm chart is in `helm/azure-webapp/`; the project scope and final-documentation requirements are tracked in `plan.md` and `docs/codex/01-IMPLEMENTATION-PLAN.md`.

**How we validated it:** Repository audit confirms there are no active HPA, ingress, Key Vault, or equivalent manifests/modules. The project still validates the selected core path: infrastructure, passwordless CI, immutable image promotion, GitOps reconciliation, Azure monitoring, and Prometheus/Grafana baseline checks.
