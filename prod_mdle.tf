# component-env-region-whatever (how we need to put the name)
provider "aws" {
    profile = "default"
    region = "us-east-1"
}

resource "aws_s3_bucket" "shebas_tf"{ # type of the resource and the name of the resource (name isfor tf)
    bucket = "shebas-bucket-mdt-2020-09-15" # name of the bucket
    acl     = "private" # politic of the bucket
}

resource "aws_default_vpc" "default"{}