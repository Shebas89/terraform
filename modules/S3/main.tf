# S3 Bucket
resource "aws_s3_bucket" "s3_bucket"{ 
    bucket  = var.bucket_name
    acl     = var.acl # politic of the bucket
}