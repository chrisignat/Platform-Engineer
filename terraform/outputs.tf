output "bucket_url" {
  value = "http://localstack.local/${aws_s3_bucket.simple_bucket.bucket}"
}