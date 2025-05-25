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
              # https://grafana.com/grafana/download?pg=oss-graf&plcmt=hero-btn-1&edition=oss
              # Red Hat, CentOS, RHEL, and Fedora(64 Bit)
              sudo yum install -y https://dl.grafana.com/oss/release/grafana-12.0.1-1.x86_64.rpm
              sudo systemctl start grafana-server
              sudo systemctl enable grafana-server
              EOF

  tags = {
    Name = "${var.name_prefix}-instance"
  }
}
