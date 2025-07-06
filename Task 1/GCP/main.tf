# Terraform & Google provider
terraform {
  required_version = ">= 1.5.0"

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
  zone    = var.zone
}

# 1. Networking  – custom VPC + public subnet
resource "google_compute_network" "vpc" {
  name                    = "wp-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "public" {
  name          = "public-subnet"
  region        = var.region
  ip_cidr_range = "10.10.1.0/24"
  network       = google_compute_network.vpc.id
}

# 2. Private-Services Access  (peering range + connection)
resource "google_compute_global_address" "sql_range" {
  name          = "sql-private-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.sql_range.name]
}

# 3. Cloud SQL  (MySQL 8, private IP)
resource "google_sql_database_instance" "mysql" {
  name                 = "wp-sql"
  database_version     = "MYSQL_8_0"
  region               = var.region
  root_password        = var.db_password
  deletion_protection  = false         # so terraform destroy works

  depends_on = [google_service_networking_connection.vpc_connection]

  settings {
    tier              = "db-f1-micro"  # always-free
    availability_type = "ZONAL"
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc.id
    }
    backup_configuration { enabled = true }
    # Labels for Cloud SQL instance
    user_labels = {
      environment = "exam"
      name        = "wp-sql"
    }
  }

  # avoid destroy ordering issue on private_network
  lifecycle {
    ignore_changes = [
      settings[0].ip_configuration[0].private_network
    ]
  }
}

resource "google_sql_database" "wordpress" {
  name     = "wordpress"
  instance = google_sql_database_instance.mysql.name
}

resource "google_sql_user" "root_user" {
  name     = "root"
  host     = "%"
  password = var.db_password
  instance = google_sql_database_instance.mysql.name
}

# 4. Compute Engine VM  (WordPress on f1-micro)
resource "google_compute_instance" "wordpress" {
  name         = "wordpress-vm"
  machine_type = "f1-micro"
  zone         = var.zone
  tags         = ["wordpress-vm"]

  boot_disk {
    initialize_params { image = "debian-cloud/debian-11" }
  }

  network_interface {
    subnetwork   = google_compute_subnetwork.public.id
    access_config {}
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    set -e
    sudo apt-get update -y
    sudo apt-get install -y apache2 php php-mysql wget unzip
    sudo systemctl enable apache2 && sudo systemctl start apache2

    cd /var/www/html
    sudo wget -q https://wordpress.org/latest.tar.gz
    sudo tar -xzf latest.tar.gz && sudo cp -r wordpress/* .
    sudo rm -rf wordpress latest.tar.gz index.html
    sudo rm -f /var/www/html/index.html
    sudo chown -R www-data:www-data /var/www/html
    
    sudo cp wp-config-sample.php wp-config.php
    sudo sed -i "s/database_name_here/wordpress/"  wp-config.php
    sudo sed -i "s/username_here/root/"            wp-config.php
    sudo sed -i "s/password_here/${var.db_password}/" wp-config.php
    sudo sed -i "s/localhost/${google_sql_database_instance.mysql.private_ip_address}/" wp-config.php
    sleep 5
    sudo systemctl restart apache2
    sleep 2
    sudo systemctl restart apache2
  EOT

  # ensure startup script gets the IP only after Cloud SQL exists
  depends_on = [google_sql_database_instance.mysql]

  labels = {
    environment = "exam"
    name        = "wordpress-vm"
  }
}

# 5. Firewall rules
# a) Allow inbound HTTP
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = google_compute_network.vpc.name
  direction = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

# b) Allow VM → CloudSQL (private range) on port 3306
resource "google_compute_firewall" "allow_sql_egress" {
  name    = "allow-sql-egress"
  network = google_compute_network.vpc.name
  direction = "EGRESS"
  priority  = 1000
  destination_ranges = ["172.18.0.0/16"]
  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }
  target_tags = ["wordpress-vm"]
}