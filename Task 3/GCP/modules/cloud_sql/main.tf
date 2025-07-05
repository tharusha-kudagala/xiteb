resource "google_sql_database_instance" "wordpress" {
  name             = "wp-sql-instance"
  region           = var.region
  database_version = "MYSQL_5_7"

  settings {
    tier = "db-f1-micro"   # exam-approved free tier
    ip_configuration {
      ipv4_enabled = true
    }
  }
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
  password = "ChangeMe123!"  # replace via tfvars, secret mgr, or CI
}

output "connection_name" {
  value = google_sql_database_instance.wordpress.connection_name
}

output "db_user" {
  value = google_sql_user.wordpress.name
}

output "db_password" {
  value = google_sql_user.wordpress.password
  sensitive = true
}

output "db_name" {
  value = google_sql_database.wordpress.name
}
