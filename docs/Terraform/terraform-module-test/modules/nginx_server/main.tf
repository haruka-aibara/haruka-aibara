resource "aws_instance" "server" {
  ami           = "ami-0c1de55b79f5aff9b"
  instance_type = var.instance_type
  tags = {
    Name = "TestWebServer"
  }
  user_data = <<EOF
#!/bin/bash
amazon-linux-extras install -y nginx1.12
systemctl start nginx
EOF
}