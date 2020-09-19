# component-env-region-whatever (how we need to put the name)
provider "aws" {
    profile = "default"
    region = "us-east-1"
}

resource "aws_s3_bucket" "shebas_tf"{ # type of the resource and the name of the resource (name isfor tf)
    bucket  = "shebas-bucket-mdt-2020-09-15" # name of the bucket
    acl     = "private" # politic of the bucket
}

resource "aws_default_vpc" "default"{}

resource "aws_security_group" "prod_mdle" {
    name        = "prod_web"
    description = "Allow http and https ports"

    ingress {
        from_port   = 80
        to_port     = 80
        protocol     = "tpc"
        cidr_blocks = ["0.0.0.0/0"] #ips range that it will be permited
    }
    ingress {
        from_port   = 443
        to_port     = 443
        protocol     = "tpc"
        cidr_blocks = ["0.0.0.0/0"] #ips range that it will be permited
    }
    egress {
        from_port   = 0 # no restrictions
        to_port     = 0 
        protocol     = "-1" # enabled all protocols 
        cidr_blocks = ["0.0.0.0/0"] #ips range that it will be permited
    }

    tags = {
        "terraform" : "true"
    }
}