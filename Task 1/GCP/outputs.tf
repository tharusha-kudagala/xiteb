output "wordpress_external_ip" {
  description = "Browse to http://<this-ip> to finish WordPress setup"
  value       = google_compute_instance.wordpress.network_interface[0].access_config[0].nat_ip
}

output "cloudsql_private_ip" {
  description = "Private IP of the Cloud SQL instance (for debugging)"
  value       = google_sql_database_instance.mysql.private_ip_address
}
