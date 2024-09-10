# aws-secure-hello-world/main.tf

provider "aws" {
  region = "ap-northeast-1" # Tokyo region
}

resource "aws_instance" "hello_world" {
  ami           = "ami-0d52744d6551d851e" # Amazon Linux 2 AMI ID for Tokyo region
  instance_type = "t3.micro"

  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name

  vpc_security_group_ids = [aws_security_group.hello_world.id]

  tags = {
    Name = "HelloWorld-SSM"
  }
}

resource "aws_security_group" "hello_world" {
  name        = "hello_world_sg"
  description = "Security group for Hello World app with SSM access"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "HelloWorld-SSM-SG"
  }
}

resource "aws_iam_role" "ssm_role" {
  name = "SSMInstanceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "SSMInstanceProfile"
  role = aws_iam_role.ssm_role.name
}

output "instance_id" {
  value       = aws_instance.hello_world.id
  description = "ID of the EC2 instance"
}
