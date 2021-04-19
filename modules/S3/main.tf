# S3 Bucket
resource "aws_s3_bucket" "prod_mdle_s3"{ 
    bucket  = var.bucketname
    acl     = var.acl # politic of the bucket
}