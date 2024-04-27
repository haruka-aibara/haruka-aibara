# ------------------------
# IAM Role
# ------------------------
resource "aws_iam_role" "app_iam_role" {
  name               = "${var.project}-${var.environment}-app-iam-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role_policy_attachment" "app_iam_role_ec2_readonly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
  role       = aws_iam_role.app_iam_role.name
}

resource "aws_iam_role_policy_attachment" "app_iam_ssm_managed" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.app_iam_role.name
}

resource "aws_iam_role_policy_attachment" "app_iam_role_ssm_readonly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
  role       = aws_iam_role.app_iam_role.name
}

resource "aws_iam_role_policy_attachment" "app_iam_role_s3_readonly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  role       = aws_iam_role.app_iam_role.name
}