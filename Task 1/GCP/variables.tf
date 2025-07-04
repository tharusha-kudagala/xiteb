variable "project_id" {
  description = "Your GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region (free tier covers several, e.g., us-central1)"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone where the VM will run"
  type        = string
  default     = "us-central1-a"
}

variable "db_password" {
  description = "Strong password for Cloud SQL root user"
  type        = string
  sensitive   = true
}
