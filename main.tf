# component-env-region-whatever (how we need to put the name)
provider "aws" {
    profile = "us-east-1"
    region = "us-east-1"
}

module "moodle_vpc" {
    source = "./modules/vpc/"
    vpc_cidr_block = "172.32.0.0/16"
}
