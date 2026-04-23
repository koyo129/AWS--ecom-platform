variable "db_username" {
  description = "Database username"
  type        = string
  default     = "adminuser"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "alert_email" {
  description = "Email address for CloudWatch alerts"
  type        = string
}
