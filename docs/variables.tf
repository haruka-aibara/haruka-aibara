variable "instance_type" {
  default = "t2.micro"
}

# ヒアドキュメントサンプル
variable "user_data" {
  default = <<EOF
#!/bin/bash
echo "Hello, World!" > /tmp/hello.txt
EOF
}