resource "google_sql_database_instance" "wordpress" {
  name             = "wp-sql-instance"
  region           = var.region
  database_version = "MYSQL_5_7"

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled = true
      authorized_networks {
        name  = "allow-all"
        value = "0.0.0.0/0"
      }
    }
  }
  deletion_protection = false
}

resource "google_sql_database" "wordpress" {
  name     = "wordpress"
  instance = google_sql_database_instance.wordpress.name
  charset  = "utf8"
  collation = "utf8_general_ci"
}

resource "google_sql_user" "wordpress" {
  name     = "wp_user"
  instance = google_sql_database_instance.wordpress.name
  password = "bDlBh3ItC2wHzEL"
}

output "connection_name" {
  value = google_sql_database_instance.wordpress.connection_name
}

output "db_user" {
  value = google_sql_user.wordpress.name
}

output "db_password" {
  value     = google_sql_user.wordpress.password
  sensitive = true
}

output "db_name" {
  value = google_sql_database.wordpress.name
}

output "public_ip_address" {
  description = "Public IP address of the Cloud SQL instance"
  value       = google_sql_database_instance.wordpress.public_ip_address
}
