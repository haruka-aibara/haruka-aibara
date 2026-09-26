# ---------------------------------------------
# IAM Group
# ---------------------------------------------
resource "aws_iam_group" "developers" {
  name = "Developers"
}

resource "aws_iam_group_policy_attachment" "developers_readonly_policy" {
  group      = aws_iam_group.developers.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_group_policy_attachment" "developers_billing_deny" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.billing_deny.arn
}

resource "aws_iam_group_policy_attachment" "developers_ec2_rebootable" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.ec2_rebootable.arn
}

resource "aws_iam_group_policy_attachment" "developers_iam_change_own_password" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.iam_change_own_password.arn
}