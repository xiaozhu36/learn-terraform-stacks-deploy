resource "random_pet" "lambda_bucket_name" {
  prefix = var.prefix
  length = var.length
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = random_pet.lambda_bucket_name.id
}

resource "aws_s3_bucket_ownership_controls" "bucket_controls" {
  bucket = aws_s3_bucket.lambda_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.bucket_controls]

  bucket = aws_s3_bucket.lambda_bucket.id
  acl    = "private"
}