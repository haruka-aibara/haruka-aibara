# GitHubActions用のIAMユーザー作成
resource "aws_iam_user" "github_actions" {
  name = "GitHubActions"
  path = "/ci/"

  tags = {
    Description = "GitHub Actions用のIAMユーザー"
  }
}

# ECS FullAccess ポリシーのアタッチ
resource "aws_iam_user_policy_attachment" "ecs_fullaccess" {
  user       = aws_iam_user.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

# EC2ContainerRegistryPowerUser ポリシーのアタッチ
resource "aws_iam_user_policy_attachment" "ecr_poweruser" {
  user       = aws_iam_user.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

# アクセスキーの作成
resource "aws_iam_access_key" "github_actions" {
  user = aws_iam_user.github_actions.name
}

# IAMロール
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

# タスク実行ロールにポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
