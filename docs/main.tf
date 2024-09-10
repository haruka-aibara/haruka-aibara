resource "aws_instance" "hello_world" {
  ami                    = "ami-xxxxxxxx" # Amazon Linux 2 AMI ID
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.hello_world.id]

  tags = {
    Name = "HelloWorld"
  }
}

resource "aws_security_group" "hello_world" {
  name        = "hello_world_sg"
  description = "Allow inbound traffic for Hello World app"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_IP_ADDRESS/32"] # Restrict SSH access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
