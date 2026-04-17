provider "aws" {
  access_key                  = "test"
  secret_key                  = "test"
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3 = "http://localhost:4566" # Χρησιμοποίησε την IP/URL που βλέπει το PC σου
  }
}

resource "aws_s3_bucket" "velero_bucket" {
  bucket = "velero-backups"
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.velero_bucket.id
  acl    = "private"
}