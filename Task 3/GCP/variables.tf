variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region (us-central1 keeps Cloud SQL f1-micro in free tier per exam spec)"
  type        = string
  default     = "us-central1"
}

variable "image_uri" {
  description = "Artifact Registry container image URI"
  type        = string
}

variable "db_user" {
  type = string
  description = "Database User"
}

variable "db_password" {
  type = string
  description = "Database Password"
  sensitive = true
}

variable "db" {
  type = string
  description = "Database Name"
}