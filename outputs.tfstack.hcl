output "lambda_urls" {
  type = list(string)
  description = "URLs to invoke lambda functions"
  value = [ for x in component.lambda: x.invoke_arn ]
}

output "s3_bucket" {
  type = map(string)
  description = "S3 bucket names"
  value = [ for x in component.s3: x.bucket_id ]
}