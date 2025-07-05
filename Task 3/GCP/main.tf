terraform {
  required_version = ">= 1.6.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Enable mandatory APIs
resource "google_project_service" "required" {
  for_each = toset([
    "run.googleapis.com",
    "sqladmin.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "iam.googleapis.com",
    "storage.googleapis.com"
  ])
  service = each.value
}

# ─────────────────────────────────────────
# MODULE INVOCATIONS
# ─────────────────────────────────────────
module "cloud_sql" {
  source = "./modules/cloud_sql"
  region = var.region
}

module "storage" {
  source     = "./modules/storage"
  project_id = var.project_id
  region     = var.region
}

module "cloud_run" {
  source                      = "./modules/cloud_run"
  project_id                  = var.project_id
  region                      = var.region
  db_instance_connection_name = module.cloud_sql.connection_name
  bucket_name                 = module.storage.bucket_name

  db_user     = module.cloud_sql.db_user
  db_password = module.cloud_sql.db_password
  db_name     = module.cloud_sql.db_name
  image_uri   = var.image_uri
}
