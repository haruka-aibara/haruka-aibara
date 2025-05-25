# セキュリティグループ
resource "aws_security_group" "grafana" {
  name        = "${var.name_prefix}-sg"
  description = "Security group for Grafana instance"
  vpc_id      = var.vpc_id

  # Grafanaのデフォルトポート
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Prometheusのデフォルトポート
  ingress {
    from_port   = 9090
    to_port     = 9090
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

  egress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP outbound traffic for node_exporter"
  }

  tags = {
    Name = "${var.name_prefix}-sg"
  }
}

# IAMロール
resource "aws_iam_role" "grafana" {
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
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.grafana.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# インスタンスプロファイル
resource "aws_iam_instance_profile" "grafana" {
  name = "${var.name_prefix}-profile"
  role = aws_iam_role.grafana.name
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
          AWS = aws_iam_role.grafana.arn
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
  role = aws_iam_role.grafana.id

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
resource "aws_s3_object" "prometheus_service" {
  bucket  = aws_s3_bucket.config.id
  key     = "prometheus/prometheus.service"
  content = <<-EOF
[Unit]
Description=Prometheus Server
Documentation=https://prometheus.io/docs/introduction/overview/
After=network-online.target

[Service]
User=root
Restart=on-failure
ExecStart=/usr/bin/prometheus-2.53.4.linux-amd64/prometheus --config.file=/usr/bin/prometheus-2.53.4.linux-amd64/prometheus.yml

[Install]
WantedBy=multi-user.target
EOF
}


# EC2インスタンス
resource "aws_instance" "grafana" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  vpc_security_group_ids = [aws_security_group.grafana.id]
  iam_instance_profile   = aws_iam_instance_profile.grafana.name

  user_data = <<-EOF
              #!/bin/bash
              # Grafanaのインストール
              sudo yum install -y https://dl.grafana.com/oss/release/grafana-12.0.1-1.x86_64.rpm
              sudo systemctl start grafana-server
              sudo systemctl enable grafana-server

              # Prometheus
              cd /usr/bin
              sudo wget https://github.com/prometheus/prometheus/releases/download/v2.53.4/prometheus-2.53.4.linux-amd64.tar.gz
              sudo tar -zxvf prometheus-2.53.4.linux-amd64.tar.gz
              sudo rm prometheus-2.53.4.linux-amd64.tar.gz

              # 設定ファイルのダウンロードと配置
              sudo aws s3 cp s3://${aws_s3_bucket.config.id}/prometheus/prometheus.service /etc/systemd/system/prometheus.service

              # サービスの有効化
              sudo systemctl daemon-reload
              sudo systemctl start prometheus
              sudo systemctl enable prometheus
              EOF

  tags = {
    Name = "${var.name_prefix}-instance"
  }

  depends_on = [aws_s3_object.prometheus_service]
}
