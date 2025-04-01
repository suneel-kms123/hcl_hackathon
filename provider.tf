terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.93.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }

  
  backend "s3" {
    bucket         = "hcl-terraform-state"
    key            = ".terraform/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "hcl-terraform-lock"
    encrypt        = true
    #profile        = "dev"
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "this" {}
data "aws_ecr_authorization_token" "this" {}
data "aws_region" "this" {}
locals { ecr_address = format("%v.dkr.ecr.%v.amazonaws.com", data.aws_caller_identity.this.account_id, data.aws_region.this.name) }

provider "docker" {
  registry_auth {
    address  = local.ecr_address
    username = data.aws_ecr_authorization_token.this.user_name
    password = data.aws_ecr_authorization_token.this.password
    #password = var.docker_password
  }
}

resource "aws_dynamodb_table" "state_locking" {
  hash_key = "LockID"
  name     = "hcl-terraform-lock"
  attribute {
    name = "LockID"
    type = "S"
  }
  billing_mode = "PAY_PER_REQUEST"
}
