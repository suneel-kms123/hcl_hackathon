module "kms"{
    source = "terraform-aws-modules/kms/aws"

    description = ""
    enable_key_rotation = true
    deletion_window_in_days = 7
    multi_region = false
    enable_default_policy = true
    enable_route53_dnssec = true

    policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-hcl-1"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:root"
          #AWS = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:SSMRole"
          "Service": "ssm.amazonaws.com"
          "Service": "logs.us-east-1.amazonaws.com"
        },
        Action   = "kms:*"
        Resource = "*"
      }    
    ]})
}