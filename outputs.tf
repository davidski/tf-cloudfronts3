output "arn" {
  value = aws_cloudfront_distribution.ssl_distribution.arn
}

output "domain_name" {
  value = aws_cloudfront_distribution.ssl_distribution.domain_name
}

output "hosted_zone_id" {
  value = aws_cloudfront_distribution.ssl_distribution.hosted_zone_id
}

output "bucket_server_arn" {
  value = aws_s3_bucket.cloudfront_bucket.arn
}
