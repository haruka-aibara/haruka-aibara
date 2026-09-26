# ECSクラスター
resource "aws_ecs_cluster" "simple_cicd" {
  name = "simple-cicd-cluster"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

# ECSタスク定義
resource "aws_ecs_task_definition" "simple_cicd" {
  family                   = "simple-cicd-def"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "dummy"
      image     = "public.ecr.aws/nginx/nginx:1.28-alpine3.21-slim"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

# ECSサービス
resource "aws_ecs_service" "simple_cicd" {
  name            = "simple-cicd-service"
  cluster         = aws_ecs_cluster.simple_cicd.id
  task_definition = aws_ecs_task_definition.simple_cicd.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_1.id, aws_subnet.public_2.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}
