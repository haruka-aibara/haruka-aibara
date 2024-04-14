variable "instance_type" {
  default = "t2.micro"
}

variable "instance_name" {
    type = string
    default = "HelloWorld"
}

# ヒアドキュメントサンプル
variable "user_data" {
  default = <<EOF
#!/bin/bash
echo "Hello, World!" > /tmp/hello.txt
EOF
}