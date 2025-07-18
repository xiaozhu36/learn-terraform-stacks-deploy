# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "random_pet" "lambda_bucket_name" {
  prefix = "hello-world-lambda"
  length = 2
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

module "s3-new" {
  source = "../modules/s3"
  prefix = "xiaozhu-test-stack-with-module"
  length = 4
}

variable "name" {
  default = "xiaozhu-test"
  type    = string
}

module "s3-v2" {
  source = "../modules/s3"
  prefix = var.name
  length = 4
}