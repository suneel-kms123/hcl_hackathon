module "ecr" {
  source          = "terraform-aws-modules/ecr/aws"
  version         = "~> 2.3.1"
  repository_name = var.ecr_name

  repository_read_write_access_arns = [module.hcl_ecs.cluster_arn]
  tags = {
    Name        = var.ecr_name
    environment = "dev"
    created_by  = "terraform"
  }
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "docker_image" "patient_service" {
  name = "${module.ecr.repository_url}/patient-service:latest"
  build {
    context = "${path.module}/../patient-service/Dockerfile"
  }

  depends_on = [module.ecr]
}

resource "docker_image" "appointment_service" {
  name = "${module.ecr.repository_url}/appointment-service:latest"
  build {
    context = "${path.module}/../appointment-service/Dockerfile"
  }
  keep_locally = false
  depends_on   = [module.ecr]
}

resource "docker_registry_image" "patient_Service_image" {
  name          = "${module.ecr.repository_url}/patient-service:latest"
  keep_remotely = true
  depends_on    = [module.ecr]
}

resource "docker_registry_image" "appointment_Service_image" {
  name          = "${module.ecr.repository_url}/appointment-service:latest"
  keep_remotely = true
  depends_on    = [module.ecr]
}
