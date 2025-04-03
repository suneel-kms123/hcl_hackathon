module "ecr" {
  source          = "terraform-aws-modules/ecr/aws"
  version         = "~> 2.3.1"
  repository_name = var.ecr_name
  repository_image_tag_mutability = "MUTABLE"

  repository_read_write_access_arns = [module.hcl_ecs.cluster_arn]
  tags = {
    Name        = var.ecr_name
    environment = "dev"
    created_by  = "terraform"
  }
  create_repository_policy = false
  repository_policy = aws_ecr_repository_policy.example.policy
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
    context = "${path.module}/patient_service"
    dockerfile = "Dockerfile"
  }

  depends_on = [module.ecr]
}

resource "docker_image" "appointment_service" {
  name = "${module.ecr.repository_url}/appointment-service:latest"
  build {
    context = "${path.module}/appointment_service"
    dockerfile = "Dockerfile"
  }
  keep_locally = false
  depends_on   = [module.ecr]
}

resource "docker_registry_image" "patient_Service_image" {
  name          = "${docker_image.patient_service.name}"
  keep_remotely = true
  depends_on    = [module.ecr]
}

resource "docker_registry_image" "appointment_Service_image" {
  name          = "${docker_image.appointment_service.name}"
  keep_remotely = true
  depends_on    = [module.ecr]
}

resource "aws_ecr_repository_policy" "example" {
  repository = module.ecr.repository_name
  policy     = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowPushPull",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::${data.aws_caller_identity.this.account_id}:root"
                ]
            },
            "Action": [
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:CompleteLayerUpload",
                "ecr:GetDownloadUrlForLayer",
                "ecr:InitiateLayerUpload",
                "ecr:PutImage",
                "ecr:UploadLayerPart"
            ]
        }
    ]

  })
}