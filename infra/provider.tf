terraform {
  required_version = ">= 1.15" 
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }

  backend "s3" {
    bucket       = "gatus-tfstate"
    key          = "terraform.tfstate"
    region       = "eu-west-2"
    use_lockfile = true
  }
}

# Configure Providers
provider "aws" {
  region = "eu-west-2"
}

provider "cloudflare" {
  api_token = var.cloudflare_token
}