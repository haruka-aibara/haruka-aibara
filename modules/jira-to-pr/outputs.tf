output "role_arn" {
  description = "IAM role the workflow assumes. Set it as the AWS_ROLE_ARN variable of the environment"
  value       = aws_iam_role.this.arn
}
