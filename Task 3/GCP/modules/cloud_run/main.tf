resource "google_artifact_registry_repository" "wp_repo" {
  provider      = google
  location      = var.region
  repository_id = "wp-app"
  format        = "DOCKER"
  description   = "WordPress container images"
}

output "artifact_repo_url" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/wp-app"
}

resource "google_cloud_run_service" "wordpress" {
  name     = "wp-cloudrun"
  location = var.region

  template {
    spec {
      containers {
        image = var.image_uri
        ports { container_port = 8080 }
        env {
          name  = "WORDPRESS_DB_HOST"
          value = var.db_instance_connection_name
        }
        env {
          name  = "WORDPRESS_DB_USER"
          value = var.db_user
        }

        env {
          name  = "WORDPRESS_DB_PASSWORD"
          value = var.db_password
        }

        env {
          name  = "WORDPRESS_DB_NAME"
          value = var.db_name
        }
        env {
          name  = "GCLOUD_STORAGE_BUCKET"
          value = var.bucket_name
        }
        env {
          name  = "APACHE_HTTP_PORT_NUMBER"
          value = "8080"
        }
      }
    }
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = "10" # 0-10 instances
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  autogenerate_revision_name = true
}

# Public access
resource "google_cloud_run_service_iam_member" "all_users" {
  service  = google_cloud_run_service.wordpress.name
  location = google_cloud_run_service.wordpress.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

output "service_url" {
  value = google_cloud_run_service.wordpress.status[0].url
}
