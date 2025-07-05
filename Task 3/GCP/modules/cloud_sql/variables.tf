variable "region" {
  type        = string
  description = "Region for Cloud SQL instance"
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