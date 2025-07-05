output "cloud_run_url" {
  description = "Public HTTP endpoint for WordPress"
  value       = module.cloud_run.service_url
}
