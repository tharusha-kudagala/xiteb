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

resource "google_project_service" "required" {
  for_each = toset([
    "run.googleapis.com",
    "sqladmin.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "iam.googleapis.com",
    "storage.googleapis.com"
  ])
  service            = each.value
  disable_on_destroy = false
}

module "cloud_sql" {
  source      = "./modules/cloud_sql"
  region      = var.region
  db          = var.db
  db_user     = var.db_user
  db_password = var.db_password
}

module "storage" {
  source     = "./modules/storage"
  project_id = var.project_id
  region     = var.region
}

resource "google_artifact_registry_repository" "wp_app" {
  location = var.region
  repository_id = "wp-app"
  format = "DOCKER"
  description = "Docker repository for wordpress app"
}

output "cloud_sql_public_ip" {
  description = "Public IP address of the Cloud SQL instance"
  value       = module.cloud_sql.public_ip_address
}

output "storage_bucket_name" {
  description = "Name of the storage bucket for uploads"
  value       = module.storage.bucket_name
}
