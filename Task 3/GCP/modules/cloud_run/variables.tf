variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "db_instance_connection_name" {
  type        = string
  description = "Cloud SQL connection name <project>:<region>:<instance>"
}

variable "bucket_name" {
  type        = string
  description = "GCS bucket for media uploads"
}

variable "db_user" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_name" {
  type = string
}

variable "image_uri" {
  description = "Full URI of the image in Artifact Registry"
  type        = string
}
