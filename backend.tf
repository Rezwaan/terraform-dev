terraform {
  backend "s3" {
    bucket = "homelike-state"
    key    = "infra/terraform.tfstate"
    region = "us-east-1"
    profile = "homelike"
    shared_credentials_file = "~/.aws/credentials"
  }
}