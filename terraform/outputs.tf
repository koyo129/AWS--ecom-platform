output "website_url" {
  description = "The URL of the website"
  value       = "http://${aws_lb.app.dns_name}"
}
