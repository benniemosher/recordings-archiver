terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  backend = "remote"
  config = {
    organization = "bam"
    workspaces = {
      name = "recordings-archiver"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  region = "us-east-2"
}
