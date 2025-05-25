output "public_ip" {
  description = "Public IP of the Exporter instance"
  value       = aws_instance.exporter.public_ip
} 
