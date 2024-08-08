terraform {
  required_providers {
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
      version = "~> 1.15.0"
    }
    aws = {
      source = "hashicorp/aws"
      version = "5.32.1"
    }
  }
}

provider "mongodbatlas" {
  # Configuration options
  public_key = var.mongodb_atlas_api_work_pub_key
  private_key  = var.mongodb_atlas_api_work_pri_key
}

provider "aws" {
  # Configuration options
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
  region     = var.aws_region
}