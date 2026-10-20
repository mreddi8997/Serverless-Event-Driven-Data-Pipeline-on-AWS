terraform {
  backend "s3" {
    bucket       = "terraform-backend-mohit"
    key          = "serverless/terraform.tfstate"
    region       = "us-east-2"
    encrypt      = true
    use_lockfile = true
  }
}
