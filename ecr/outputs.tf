output "rest_api_ecr_repo_url" {
  value = "${aws_ecr_repository.ecr_bc_restapi.repository_url}:latest"
}