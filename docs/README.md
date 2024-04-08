
main.tf:

provider "aws" {
  region = var.region
}

locals {
  common_tags = {
    Environment = "dev"
    Project     = "my-project"
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags       = merge(local.common_tags, { Name = "my-vpc" })
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.region}a"
  tags              = merge(local.common_tags, { Name = "public-subnet" })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.common_tags, { Name = "my-igw" })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(local.common_tags, { Name = "public-rt" })
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "allow-ssh-sg" })
}

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  tags          = merge(local.common_tags, { Name = "example-ec2" })
}

resource "aws_ebs_volume" "example" {
  availability_zone = "${var.region}a"
  size              = 10
  tags              = merge(local.common_tags, { Name = "example-ebs" })
}

resource "aws_volume_attachment" "example" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.example.id
  instance_id = aws_instance.example.id
}
variables.tf:

variable "region" {
  default = "us-west-2"
}

variable "instance_type" {
  default = "t2.micro"
}
outputs.tf:

output "public_ip" {
  value = aws_instance.example.public_ip
}
