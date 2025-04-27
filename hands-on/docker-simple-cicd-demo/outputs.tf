# GitHub Actions関連の出力値
output "github_actions_user_arn" {
  value = aws_iam_user.github_actions.arn
}

output "github_actions_access_key_id" {
  value = aws_iam_access_key.github_actions.id
}

output "github_actions_secret_access_key" {
  value     = aws_iam_access_key.github_actions.secret
  sensitive = true
}

# インフラ関連の出力値
output "vpc_id" {
  value = aws_vpc.simple_cicd.id
}

output "public_subnet_ids" {
  value = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

output "security_group_id" {
  value = aws_security_group.ecs_sg.id
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.simple_cicd.name
}

output "ecs_service_name" {
  value = aws_ecs_service.simple_cicd.name
}
