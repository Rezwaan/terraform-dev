#### S3 buckets
resource "random_integer" "rand" {
  min = 10000
  max = 99999
}

locals {
  bucket_name = "${var.aws_bucket_prefix}-${random_integer.rand.result}"
}

resource "aws_s3_bucket" "logs_bucket" {
  bucket        = local.bucket_name
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

}