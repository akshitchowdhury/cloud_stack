output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.cloud_stack.public_ip
}

output "app_url" {
  description = "URL to access the app"
  value       = "http://${aws_instance.cloud_stack.public_ip}"
}