# プロバイダー
provider "aws" {
  profile = "default"
  region  = "ap-northeast-1"
}

# サンプルインスタンス
resource "aws_instance" "hello-world" {
  ami           = "ami-0992fc94ca0f1415a"
  instance_type = "t2.micro"

  tags = {
    Name = "HelloWorld"
  }

  user_data = <<EOF
#!/bin/bash
amazon-linux-extras install -y nginx1.12
systemctl start ngnix
EOF
}