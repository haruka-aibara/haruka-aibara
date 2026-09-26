resource "aws_ecr_repository" "web" {
  name = "simple-cicd-web"
  # trivy:ignore:AWS-0031
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    # trivy:ignore:AWS-0030
    scan_on_push = false
  }
  force_delete = true
}

resource "aws_ecr_repository" "api" {
  name = "simple-cicd-api"
  # trivy:ignore:AWS-0031
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    # trivy:ignore:AWS-0030
    scan_on_push = false
  }
  force_delete = true
}
