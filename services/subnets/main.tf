# component-env-region-whatever (how we need to put the name)
provider "aws" {
    profile = "us-east-1"
    region  = "us-east-1"
}

module "subnets" {
    source = "./modules/subnets"

    vpc_id = ""

}