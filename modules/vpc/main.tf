resource "aws_vpc" "prod_mdle_vpc" { 
    cidr_block  = var.vpc_cidr_block
    enable_dns_support   = true
    enable_dns_hostnames = true

    tags = {
        Name = "prod_mdle"
        "Terraform" : "true"
    }
}