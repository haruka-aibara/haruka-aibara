# S3バケットの作成
resource "aws_s3_bucket" "ansible_files" {
  bucket = var.s3_bucket_name

  tags = {
    Name = "${var.project_name}-ansible-files"
  }
}

# S3バケットの暗号化設定
resource "aws_s3_bucket_server_side_encryption_configuration" "ansible_files" {
  bucket = aws_s3_bucket.ansible_files.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3バケットのパブリックアクセスブロック設定
resource "aws_s3_bucket_public_access_block" "ansible_files" {
  bucket = aws_s3_bucket.ansible_files.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Ansibleファイルのアップロード
resource "aws_s3_object" "ansible_cfg" {
  bucket = aws_s3_bucket.ansible_files.id
  key    = "ansible.cfg"
  source = "${path.module}/ansible/ansible.cfg"
  etag   = filemd5("${path.module}/ansible/ansible.cfg")
}

resource "aws_s3_object" "ansible_inventory" {
  bucket = aws_s3_bucket.ansible_files.id
  key    = "inventory/aws_ec2.yml"
  source = "${path.module}/ansible/inventory/aws_ec2.yml"
  etag   = filemd5("${path.module}/ansible/inventory/aws_ec2.yml")
}

resource "aws_s3_object" "ansible_playbook" {
  bucket = aws_s3_bucket.ansible_files.id
  key    = "playbooks/${var.ansible_playbook_name}"
  source = "${path.module}/ansible/playbooks/${var.ansible_playbook_name}"
  etag   = filemd5("${path.module}/ansible/playbooks/${var.ansible_playbook_name}")
}
