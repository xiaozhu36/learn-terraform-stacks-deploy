# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

identity_token "aws" {
  audience = ["aws.workload.identity"]
}

# deployment "development" {
#   inputs = {
#     regions        = ["us-east-1"]
#     role_arn       = "arn:aws:iam::954932251222:role/stacks-xiaozhu-prj-AVstYBB7RFBWZf6s"
#     identity_token = identity_token.aws.jwt
#     default_tags   = { stacks-preview-example = "lambda-component-expansion-stack" }
#   }
# }

deployment "production" {
  inputs = {
    regions        = ["us-east-1"]
    role_arn       = "arn:aws:iam::954932251222:role/stacks-xiaozhu-prj-AVstYBB7RFBWZf6s"
    identity_token = identity_token.aws.jwt
    default_tags   = { stacks-preview-example = "lambda-component-expansion-stack" }
    buckent_name = upstaream_input.upstream_stack_name.bucket_names[0]
  }
}

upstream_input "upstream_stack_name" {
  type   = "stack"
  source = "app.terraform.io/xiaozhu/prj-AVstYBB7RFBWZf6s/xiaozhu-deploy-stack-dev"
}