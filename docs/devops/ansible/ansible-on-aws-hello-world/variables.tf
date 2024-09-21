variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0d52744d6551d851e" # Amazon Linux 2 AMI ID for Tokyo region
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "HelloWorld-SSM"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for Ansible files"
  type        = string
  default     = "aibara-ha-ansible-on-aws-hello-world"
}

variable "ansible_playbook_name" {
  description = "Name of the default Ansible playbook"
  type        = string
  default     = "hello_world.yml"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
