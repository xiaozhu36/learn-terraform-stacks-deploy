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

terraform {
  backend "oss" {
    region              = "ap-southeast-1"
    bucket              = "bucket-iac-03"
    prefix              = "state/s3"
    key                 = "terraform.tfstate"
    access_key = "STS.NXae8hDRwiXiZEJ6pT2UWGPUu"
    security_token = "CAIS2wJ1q6Ft5B2yfSjIr5vULoLcqY1W3pqCWGP70nABPtp7qJX+lzz2IHhMdHBtA+4XtvgznW5S7vgalqZvRoVfTELDd8419Yhe+gD55BEoJiTuv9I+k5SANTW5KXyShb3/AYjQSNfaZY3eCTTtnTNyxr3XbCirW0ffX7SClZ9gaKZ8PGD6F00kYu1bPQx/ssQXGGLMPPK2SH7Qj3HXEVBjt3gX6wo9y9zmm53GtUCD1gamkbZE+9iuGPX+MZkwZqUYesyuwel7epDG1CNt8BVQ/M509vccoWee44vDUgENv0zYabKKqscmIghjI7Q3ALIBsPXmj+dxtOvJksHs1x9GPqRfWi/cSYas0HRspWArqzJTn9/aTJeturjnXvGd24h09v2ny21BMhytfsq8tbjo7uXGa87BthmDKSyocMO+u+pNmqFW9DbTnvnBSjbCPfP3mEh3NPeMr1YCanZ+tRqAAR7t4lkDv4X6jzvI+4FeHiPIx2IK3c+fqXYN5HPjcGi9rBHc1AEJZNBm8x/JV/hyHxKTu8VHMTMG09HQV2jzgsTN+wo0nbg6YgWNRA4o9HoagVqYEOxy4nNs9E69YJDYGFfMOd80rt8iIU0dxFKKccgHNhs+7V1L3SOp9Ajk/WZZIAA="
    secret_key= "CeNfZYG7uYsHmGi7gHV11dua4ThoBm6YMrkk9HsjrzZG"
  }
}