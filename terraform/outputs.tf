output "website_url" {
  description = "The URL of the website"
  value       = "http://${aws_lb.app.dns_name}"
}

output "rds_endpoint" {
  description = "The RDS endpoint"
  value       = aws_db_instance.postgres.address
}
