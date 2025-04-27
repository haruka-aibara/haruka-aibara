# セキュリティグループ
resource "aws_security_group" "ecs_sg" {
  name        = "simple-cicd-sg"
  description = "Allow inbound traffic for ECS service"
  vpc_id      = aws_vpc.simple_cicd.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "simple-cicd-sg"
  }
}
