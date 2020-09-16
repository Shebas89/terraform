provider "aws" {
    profile = "default"
    region = "us_west-1"
}

resourse "aws_s3_bucket" "shebas_tf"{
    buecket = "shebas_buecket_mdt"
    acl     = "public-read-write"
}