output "public_ip" {
  description = "Public IP of the Grafana instance"
  value       = aws_instance.grafana.public_ip
}

output "grafana_url" {
  description = "URL to access Grafana"
  value       = "http://${aws_instance.grafana.public_ip}:3000"
} 
