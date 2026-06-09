variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "Name of the EC2 key pair for SSH"
  type        = string
}

variable "your_ip" {
  description = "Your IP address for SSH access (CIDR format)"
  type        = string
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "test_zero"
}

variable "db_user" {
  description = "PostgreSQL username"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
}

variable "github_repo" {
  description = "Full HTTPS URL of your monorepo"
  type        = string
}