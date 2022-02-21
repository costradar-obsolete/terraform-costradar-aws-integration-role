terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.70"
    }
    costradar = {
      source = "costradar/"
    }
  }
  required_version = ">= 0.14"
}

provider "aws" {}

provider "costradar" {}

data "aws_caller_identity" "current" {}

data "costradar_integration_config" "current" {}

module "costradar_integration_role" {
  source  = "costradar/aws-integration-role/costradar"
  version = "0.1.2"
}