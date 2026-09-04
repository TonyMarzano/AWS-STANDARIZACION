terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket         = "tf-state-<cliente>"
    key            = "prod/network/terraform.tfstate"
    region         = "<home-region>"
    dynamodb_table = "tf-locks-<cliente>"
    encrypt        = true
  }
}
