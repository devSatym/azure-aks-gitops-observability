Phase 3 — GitHub Actions and OIDC
Objective

The objective of this phase was to automate the Docker image build and delivery process using GitHub Actions.

GitHub Actions authenticates to Azure using OpenID Connect instead of a stored client secret.

Why OIDC Was Used

Traditional service principal authentication commonly stores a client secret in GitHub.

OIDC provides:

Passwordless Azure authentication
Short-lived authentication tokens
Reduced secret-management overhead
Improved CI/CD security
Federated trust between GitHub and Microsoft Entra ID
Authentication Flow
GitHub Actions Workflow
   ↓
GitHub OIDC Token
   ↓
Microsoft Entra App Registration
   ↓
Federated Identity Credential
   ↓
Azure Access Token
   ↓
Authorised Azure Operations
CI Workflow
Application Code Change
   ↓
Git Push
   ↓
GitHub Actions
   ↓
Azure Login Using OIDC
   ↓
Docker Image Build
   ↓
Commit-Based Image Tag
   ↓
Push Image to Azure Container Registry
Required GitHub Secrets

The workflow uses the following GitHub secrets:

Secret	Purpose
AZURE_CLIENT_ID	Application registration client ID
AZURE_TENANT_ID	Microsoft Entra tenant ID
AZURE_SUBSCRIPTION_ID	Azure subscription ID
Required GitHub Variables

The workflow uses repository variables such as:

Variable	Purpose
ACR_NAME	Azure Container Registry name
ACR_LOGIN_SERVER	Full ACR login server
AKS_RESOURCE_GROUP	AKS resource group
AKS_CLUSTER_NAME	AKS cluster name
IMAGE_NAME	Container image repository name
DEPLOYMENT_NAME	Kubernetes Deployment name
GitHub Actions Responsibilities

GitHub Actions performs:

Repository checkout
Azure authentication using OIDC
Docker image build
Commit-based image tagging
Authentication to ACR
Image push to ACR

The workflow should be named according to its actual responsibility:

name: Build and Push Application Image

GitHub Actions should not be described as the Kubernetes deployment owner when Argo CD controls deployment.

Image Tagging

A shortened Git commit SHA can be used as the image tag:

IMAGE_TAG=${GITHUB_SHA::7}

Example:

ram-aks-web:a1b2c3d

Commit-based tags improve traceability between:

Source code
GitHub Actions run
Container image
Kubernetes release
Workflow File
.github/workflows/deploy-aks.yml

The file can later be renamed to something clearer:

.github/workflows/build-push-image.yml
ACR Validation

List image tags:

az acr repository show-tags \
  --name <acr-name> \
  --repository ram-aks-web \
  --output table
Evidence




Outcome

This phase implemented secure and repeatable continuous integration for Docker image creation and delivery to Azure Container Registry.