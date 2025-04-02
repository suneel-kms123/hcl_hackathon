module "hcl_ecs" {
  source       = "terraform-aws-modules/ecs/aws"
  cluster_name = "hcl_ecs"
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }
  tags = {
    Name        = "hcl_ecs"
    environment = "dev"
    created_by  = "terraform"
  }
  depends_on = [module.vpc.hcl_vpc]
}

locals {
    patient_container_name = "patient-service"
    appointment_container_name = "appointment-service"
    patient_container_port = 8080 
    appointment_container_port = 8081
    example        = "healthCare"
}

data "aws_iam_role" "ecs_task_execution_role" { name = "ecsTaskExecutionRole" }

data "aws_iam_role" "ecs_task_role" { name = "ecsTaskRole" }
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = data.aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
resource "aws_iam_role_policy_attachment" "ecs_task_role" {
  role       = data.aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_ecs_task_definition" "patient_service_definition" {
  container_definitions = jsonencode([{
    environment : [
      { name = "NODE_ENV", value = "production" }
    ],
    essential    = true,
    image        = resource.docker_registry_image.patient_Service_image.name,
    name         = local.patient_container_name,
    portMappings = [{ containerPort = local.patient_container_port }],
  }])
  cpu                      = 256
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  family                   = "family-of-${local.example}-tasks"
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
}


resource "aws_ecs_service" "patient_service" {
  cluster         = module.hcl_ecs.cluster_id
  desired_count   = 1
  launch_type     = "FARGATE"
  name            = "${local.example}-patient-service"
  task_definition = resource.aws_ecs_task_definition.patient_service_definition.arn

  lifecycle {
    ignore_changes = [desired_count] # Allow external changes to happen without Terraform conflicts, particularly around auto-scaling.
  }

  load_balancer {
    container_name = local.patient_container_port
    container_port = local.patient_container_port
    #target_group_arn = aws_alb.hcl_main.arn
    target_group_arn = aws_alb_target_group.hcl_app.arn
  }

  network_configuration {
    security_groups = [module.vpc.default_security_group_id]
    subnets         = module.vpc.private_subnets
  }
}


resource "aws_ecs_task_definition" "appointment_service_definition" {
  container_definitions = jsonencode([{
    environment : [
      { name = "NODE_ENV", value = "production" }
    ],
    essential    = true,
    image        = resource.docker_registry_image.appointment_Service_image.name,
    name         = local.appointment_container_name,
    portMappings = [{ containerPort = local.appointment_container_port }],
  }])
  cpu                      = 256
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  family                   = "family-of-${local.example}-tasks"
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
}



resource "aws_ecs_service" "appointment_service" {
  cluster         = module.hcl_ecs.cluster_id
  desired_count   = 1
  launch_type     = "FARGATE"
  name            = "${local.example}-appointment-service"
  task_definition = resource.aws_ecs_task_definition.appointment_service_definition.arn

  lifecycle {
    ignore_changes = [desired_count] # Allow external changes to happen without Terraform conflicts, particularly around auto-scaling.
  }

  load_balancer {
    container_name = local.appointment_container_name
    container_port = local.appointment_container_port
    target_group_arn = aws_alb_target_group.hcl_app.arn
  }

  network_configuration {
    security_groups = [module.vpc.default_security_group_id]
    subnets         = module.vpc.private_subnets
  }
}