# サンプルインスタンス　インスタンスタイプ
variable "instance_type" {
  default = "t2.micro"
}

# サンプルインスタンス　インスタンス名
variable "instance_name" {
  type    = string
  default = "HelloWorld"
}

# ヒアドキュメントサンプル
variable "user_data" {
  default = <<EOF
#!/bin/bash
echo "Hello, World!" > /tmp/hello.txt
EOF
}

# プリミティブ型 string型 変数テスト
variable "test" {
  type    = string
  default = "test"
}

# プリミティブ型 number型 変数テスト
variable "instance_count" {
  type    = number
  default = 2
}

# プリミティブ型　bool型　変数テスト
variable "enable_monitoring" {
  type    = bool
  default = true
}

# 構造体 object型 変数テスト
variable "tags" {
  type = object({
    env = string
    app = string
  })
  default = {
    env = "dev"
    app = "my-test-app"
  }
}

# 構造体 tuple型 変数テスト
variable "instance_types" {
  type    = tuple([string, number, bool])
  default = ["t2.micro", 2, true]
}

# コレクション型 list型 変数テスト
variable "availability_zones" {
  type    = list(string)
  default = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

# コレクション型 map型 変数テスト
variable "instance_type_map" {
  type = map(string)
  default = {
    small  = "t2.micro"
    medium = "t2.medium"
    large  = "t2.large"
  }
}

# コレクション型 set型 変数テスト
variable "allowed_ips" {
  type    = set(string)
  default = ["192.168.0.1", "192.168.0.2", "192.168.0.3"]
}

# 環境変数テスト（外部でexport TF_VAR_I
variable "instance_description" {
  type = string
}