resource "google_storage_bucket" "uploads" {
  name          = "${var.project_id}-wp-uploads"
  location      = var.region
  force_destroy = true

  lifecycle_rule {
    action { type = "Delete" }
    condition { age = 90 } # auto-purge old objects
  }
}

output "bucket_name" {
  value = google_storage_bucket.uploads.name
}
