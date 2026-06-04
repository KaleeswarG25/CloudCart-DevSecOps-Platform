terraform {
  required_version = ">= 1.3.0"

  backend "s3" {
    bucket         = "cloudcart-terraform-state-eswar-2026" # 👈 Updated with your real bucket name
    key            = "cloudcart/production/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}
