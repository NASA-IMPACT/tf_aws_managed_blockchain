
resource "aws_ecr_repository" "app-ecr" {
  name = "${var.ecs-cluster-name}-ecr"
}


resource "null_resource" "ecr-image-build-push" {
  triggers = {
    folder_change = sha1(join("", [for f in fileset(var.ecs_container_folder_path, "*") : filesha1("${var.ecs_container_folder_path}/${f}")]))
  }

  provisioner "local-exec" {
    command = <<EOF
           aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com
           docker build -t ${aws_ecr_repository.app-ecr.repository_url}:latest "${path.module}/../application/os-blockchain-api/"
           docker push ${aws_ecr_repository.app-ecr.repository_url}:latest
       EOF
  }
}