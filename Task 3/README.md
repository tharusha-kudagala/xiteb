# Task 3 – WordPress on Cloud Run (Terraform)

This repo provisions, with **Terraform 1.6+**:

1. **Cloud SQL** – `db-f1-micro` MySQL (exam-approved free tier)
2. **Cloud Storage** bucket – media uploads (5 GB/month free tier)
3. **Artifact Registry** – holds built WP image if desired
4. **Cloud Run** – Bitnami WordPress container, auto-scales 0-10

## Prerequisites

* gcloud CLI authenticated to the correct project
* Terraform ≥ 1.6

## Usage

```bash
terraform init
terraform apply -auto-approve \
  -var \"project_id=<YOUR-PROJECT>\" \
  -var \"region=us-central1\"


gcloud services enable iam.googleapis.com \
                       iamcredentials.googleapis.com \
                       sts.googleapis.com \
                       cloudresourcemanager.googleapis.com

gcloud iam workload-identity-pools create "github-pool" \
  --project="xiteb-464906" \
  --location="global" \
  --display-name="GitHub Actions Pool"

gcloud iam workload-identity-pools describe "github-pool" \
  --project="xiteb-464906" \
  --location="global" \
  --format="value(name)"

projects/61419581461/locations/global/workloadIdentityPools/github-pool

gcloud iam workload-identity-pools providers create-oidc "github-provider" \
  --project="xiteb-464906" \
  --location="global" \
  --workload-identity-pool="github-pool" \
  --display-name="GitHub Provider" \
  --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository" \
  --attribute-condition="attribute.repository=='harusha-kudagala/xiteb'" \
  --issuer-uri="https://token.actions.githubusercontent.com"

gcloud iam service-accounts add-iam-policy-binding github-actions@xiteb-464906.iam.gserviceaccount.com \
  --project="xiteb-464906" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/61419581461/locations/global/workloadIdentityPools/github-pool/attribute.repository/tharusha-kudagala/xiteb"

