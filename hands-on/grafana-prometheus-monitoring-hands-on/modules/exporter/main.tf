# セキュリティグループ
resource "aws_security_group" "exporter" {
  name        = "${var.name_prefix}-sg"
  description = "Security group for Exporter instance"
  vpc_id      = var.vpc_id

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

  tags = {
    Name = "${var.name_prefix}-instance"
  }
} 
