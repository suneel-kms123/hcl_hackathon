module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"
  name    = var.vpc_name
  cidr    = var.cidr

  tags = {
    Name        = "hcl_vpc"
    terraform   = "true"
    environment = "dev"
    created_by  = "terraform"
  }
}