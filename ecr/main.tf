
resource "aws_ecr_repository" "ecr_bc_restapi" {
  name = "${var.prefix}-blockchain-restapi"
}


resource "null_resource" "build_ecr_image" {
 triggers = {
   now = timestamp()
 }

 provisioner "local-exec" {
   command = <<EOF
          cd ${var.ecs_container_folder_path}
          aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com
          docker build -t ${aws_ecr_repository.ecr_bc_restapi.repository_url}:latest .
          docker push ${aws_ecr_repository.ecr_bc_restapi.repository_url}:latest
          cd -
       EOF
 }
}