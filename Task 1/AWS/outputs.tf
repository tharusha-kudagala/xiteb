output "wordpress_url" {
  value       = aws_lb.alb.dns_name
  description = "Open this in your browser to finish WP setup"
}
