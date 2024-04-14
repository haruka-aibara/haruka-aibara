# サンプルインスタンス　インスタンスタイプ
variable "instance_type" {
  default = "t2.micro"
}

# サンプルインスタンス　インスタンス名
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

# プリミティブ型の変数テスト
variable "test" {
    type = string
    default = "test"
}