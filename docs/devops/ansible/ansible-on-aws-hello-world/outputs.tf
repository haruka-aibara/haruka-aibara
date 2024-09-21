output "instance_id" {
  value       = aws_instance.hello_world.id
  description = "ID of the EC2 instance"
}

output "instance_public_ip" {
  value       = aws_instance.hello_world.public_ip
  description = "Public IP address of the EC2 instance"
}

output "ssm_document_name" {
  value       = aws_ssm_document.ansible_playbook.name
  description = "Name of the SSM document for Ansible playbook execution"
}
