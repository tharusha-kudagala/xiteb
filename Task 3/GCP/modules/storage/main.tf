resource "google_storage_bucket" "uploads" {
  name          = "${var.project_id}-wp-uploads"
  location      = var.region
  force_destroy = true

  versioning {
    enabled = true
  }
  lifecycle_rule {
    action { type = "Delete" }
    condition { num_newer_versions = 1 }
  }
}

output "bucket_name" {
  value = google_storage_bucket.uploads.name
}
