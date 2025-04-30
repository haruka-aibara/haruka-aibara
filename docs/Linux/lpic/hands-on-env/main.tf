provider "aws" {
  region = "ap-northeast-1"
}

# VPC
resource "aws_vpc" "lpic" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# プライベートサブネット
resource "aws_subnet" "lpic_private" {
  vpc_id                  = aws_vpc.lpic.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = false
}

# セキュリティグループ
resource "aws_security_group" "lpic" {
  name        = "lpic-ssh-sg"
  description = "Allow SSH inbound traffic from EC2 Instance Connect"
  vpc_id      = aws_vpc.lpic.id

  ingress {
    description = "SSH from EC2 Instance Connect"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# VPCエンドポイントの作成（EC2インスタンスコネクト用）
resource "aws_ec2_instance_connect_endpoint" "example" {
  subnet_id = aws_subnet.lpic_private.id
}

# EC2インスタンスの作成
resource "aws_instance" "lpic" {
  ami                         = "ami-0b20f552f63953f0e" # Ubuntu Server 24.04 LTS
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.lpic_private.id
  vpc_security_group_ids      = [aws_security_group.lpic.id]
  associate_public_ip_address = false
}
