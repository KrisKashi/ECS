terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

backend "s3" {
    bucket = "gatus-tfstate"
    key    = "terraform.tfstate"
    region = "eu-west-2"
    use_lockfile = true
    }
}

# Configure the AWS Provider
provider "aws" {
    region = "eu-west-2"
}