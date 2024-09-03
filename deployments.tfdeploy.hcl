# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

deployment "development" {
  inputs = {
    regions        = ["us-east-1"]
    default_tags   = { stacks-preview-example = "lambda-component-expansion-stack" }
  }
}

deployment "production" {
  inputs = {
    regions        = ["us-east-1", "us-west-1"]
    default_tags   = { stacks-preview-example = "lambda-component-expansion-stack" }
  }
}

