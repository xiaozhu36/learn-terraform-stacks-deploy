# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "random_pet" "api_gateway_name" {
  prefix = "hello-world-lambda-gw"
  length = 2
}

resource "aws_apigatewayv2_api" "lambda" {
  name          = random_pet.api_gateway_name.id
  protocol_type = "HTTP"
}
#
# resource "aws_apigatewayv2_stage" "lambda" {
#   api_id = aws_apigatewayv2_api.lambda.id
#
#   name        = "serverless_lambda_stage"
#   auto_deploy = true
#
#   access_log_settings {
#     destination_arn = aws_cloudwatch_log_group.api_gw.arn
#
#     format = jsonencode({
#       requestId               = "$context.requestId"
#       sourceIp                = "$context.identity.sourceIp"
#       requestTime             = "$context.requestTime"
#       protocol                = "$context.protocol"
#       httpMethod              = "$context.httpMethod"
#       resourcePath            = "$context.resourcePath"
#       routeKey                = "$context.routeKey"
#       status                  = "$context.status"
#       responseLength          = "$context.responseLength"
#       integrationErrorMessage = "$context.integrationErrorMessage"
#       }
#     )
#   }
# }
#
# resource "aws_apigatewayv2_integration" "hello_world" {
#   api_id = aws_apigatewayv2_api.lambda.id
#
#   integration_uri    = var.lambda_invoke_arn
#   integration_type   = "AWS_PROXY"
#   integration_method = "POST"
# }
#
# resource "aws_apigatewayv2_route" "hello_world" {
#   api_id = aws_apigatewayv2_api.lambda.id
#
#   route_key = "GET /hello"
#   target    = "integrations/${aws_apigatewayv2_integration.hello_world.id}"
# }
#
# resource "aws_cloudwatch_log_group" "api_gw" {
#   name = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}"
#
#   retention_in_days = 30
# }
#
# resource "aws_lambda_permission" "api_gw" {
#   statement_id  = "AllowExecutionFromAPIGateway"
#   action        = "lambda:InvokeFunction"
#   function_name = var.lambda_function_name
#   principal     = "apigateway.amazonaws.com"
#
#   source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
# }

terraform {
  backend "oss" {
    region              = "ap-southeast-1"
    bucket              = "bucket-iac-03"
    prefix              = "state/api"
    key                 = "terraform.tfstate"
    access_key = "STS.NXae8hDRwiXiZEJ6pT2UWGPUu"
    security_token = "CAIS2wJ1q6Ft5B2yfSjIr5vULoLcqY1W3pqCWGP70nABPtp7qJX+lzz2IHhMdHBtA+4XtvgznW5S7vgalqZvRoVfTELDd8419Yhe+gD55BEoJiTuv9I+k5SANTW5KXyShb3/AYjQSNfaZY3eCTTtnTNyxr3XbCirW0ffX7SClZ9gaKZ8PGD6F00kYu1bPQx/ssQXGGLMPPK2SH7Qj3HXEVBjt3gX6wo9y9zmm53GtUCD1gamkbZE+9iuGPX+MZkwZqUYesyuwel7epDG1CNt8BVQ/M509vccoWee44vDUgENv0zYabKKqscmIghjI7Q3ALIBsPXmj+dxtOvJksHs1x9GPqRfWi/cSYas0HRspWArqzJTn9/aTJeturjnXvGd24h09v2ny21BMhytfsq8tbjo7uXGa87BthmDKSyocMO+u+pNmqFW9DbTnvnBSjbCPfP3mEh3NPeMr1YCanZ+tRqAAR7t4lkDv4X6jzvI+4FeHiPIx2IK3c+fqXYN5HPjcGi9rBHc1AEJZNBm8x/JV/hyHxKTu8VHMTMG09HQV2jzgsTN+wo0nbg6YgWNRA4o9HoagVqYEOxy4nNs9E69YJDYGFfMOd80rt8iIU0dxFKKccgHNhs+7V1L3SOp9Ajk/WZZIAA="
    secret_key= "CeNfZYG7uYsHmGi7gHV11dua4ThoBm6YMrkk9HsjrzZG"
  }
}