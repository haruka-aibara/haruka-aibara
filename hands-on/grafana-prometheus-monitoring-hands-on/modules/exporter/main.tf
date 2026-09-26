# セキュリティグループ
resource "aws_security_group" "exporter" {
  name        = "${var.name_prefix}-sg"
  description = "Security group for Exporter instance"
  vpc_id      = var.vpc_id

  # Node Exporterのデフォルトポート
  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # アウトバウンドトラフィック
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS outbound traffic for Session Manager"
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP outbound traffic for package updates"
  }

  tags = {
    Name = "${var.name_prefix}-sg"
  }
}

# S3バケットの作成
resource "aws_s3_bucket" "config" {
  bucket = "${var.name_prefix}-config-${random_string.suffix.result}"
}

# ランダムな文字列を生成（バケット名の重複を防ぐため）
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# S3バケットのポリシー
resource "aws_s3_bucket_policy" "config" {
  bucket = aws_s3_bucket.config.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.exporter.arn
        }
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.config.arn,
          "${aws_s3_bucket.config.arn}/*"
        ]
      }
    ]
  })
}

# S3バケットへのアクセス権限を追加
resource "aws_iam_role_policy" "s3_access" {
  name = "${var.name_prefix}-s3-access"
  role = aws_iam_role.exporter.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.config.arn,
          "${aws_s3_bucket.config.arn}/*"
        ]
      }
    ]
  })
}

# 設定ファイルをS3にアップロード
resource "aws_s3_object" "node_exporter_service" {
  bucket  = aws_s3_bucket.config.id
  key     = "node_exporter/node_exporter.service"
  content = <<-EOF
[Unit]
Description=Node Exporter
Documentation=https://prometheus.io/docs/introduction/overview/
After=network-online.target

[Service]
User=root
Restart=on-failure
ExecStart=/usr/bin/node_exporter-1.9.1.linux-amd64/node_exporter

[Install]
WantedBy=multi-user.target 
EOF
}

# IAMロール
resource "aws_iam_role" "exporter" {
  name = "${var.name_prefix}-role"

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

# SSM用のポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "exporter_ssm_policy" {
  role       = aws_iam_role.exporter.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# インスタンスプロファイル
resource "aws_iam_instance_profile" "exporter" {
  name = "${var.name_prefix}-profile"
  role = aws_iam_role.exporter.name
}

# EC2インスタンス
resource "aws_instance" "exporter" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  vpc_security_group_ids = [aws_security_group.exporter.id]
  iam_instance_profile   = aws_iam_instance_profile.exporter.name

  user_data = <<-EOF
              #!/bin/bash
              # Node Exporterのインストール
              cd /usr/bin
              sudo wget https://github.com/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-amd64.tar.gz
              sudo tar -zxvf node_exporter-1.9.1.linux-amd64.tar.gz
              sudo rm node_exporter-1.9.1.linux-amd64.tar.gz

              # 設定ファイルのダウンロードと配置
              sudo aws s3 cp s3://${aws_s3_bucket.config.id}/node_exporter/node_exporter.service /etc/systemd/system/node_exporter.service

              # サービスの有効化
              sudo systemctl daemon-reload
              sudo systemctl start node_exporter
              sudo systemctl enable node_exporter
              EOF

  tags = {
    Name = "${var.name_prefix}-instance"
  }

  depends_on = [aws_s3_object.node_exporter_service]
}
