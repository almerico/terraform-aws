output "ecr_repository_url" {
  value = aws_ecr_repository.docker_image_repo_front.repository_url
}

//THis is test later have to add all neede repos
resource "aws_ecr_repository" "docker_image_repo_front" {
  name                 = "frontend"
  image_tag_mutability = "MUTABLE"

  tags = {
    Name      = var.project_name
    CreatedBy = "terraform"
  }
}
