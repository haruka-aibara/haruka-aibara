# プロバイダー
provider "aws" {
  profile = "default"
  region  = "ap-northeast-1"
}

# サンプルインスタンス
resource "aws_instance" "hello-world" {
  ami           = "ami-031134f7a79b6e424"
  instance_type = "t2.micro"

  tags = {
    Name = "${var.instance_name}"
    Project = "${local.project}"
  }


# 1行コメントサンプル

/*
複数行コメントサンプル
複数行コメントサンプル
*/

  user_data = <<EOF
#!/bin/bash
amazon-linux-extras install -y nginx1.12
systemctl start ngnix
EOF
}