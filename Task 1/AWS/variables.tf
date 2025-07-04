variable "key_name" {
  description = "Existing EC2 key-pair name for SSH"
  type        = string
}

variable "db_password" {
  description = "Strong password for the RDS admin user"
  type        = string
  sensitive   = true
}
