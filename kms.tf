module "kms"{
    source = "terraform-aws-modules/kms/aws"

    description = ""
    enable_key_rotation = true
    deletion_window_in_days = 7
    multi_region = false
    enable_default_policy = true
    enable_route53_dnssec = true
    grants = {
       
    }
}