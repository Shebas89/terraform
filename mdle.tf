provider "aws" {
    profile = "default"
    region = "us-east-1"
}

resource "aws_s3_bucket" "shebas_tf"{
    bucket = "shebas-bucket-mdt-2020-09-15"
    acl     = "private"
}