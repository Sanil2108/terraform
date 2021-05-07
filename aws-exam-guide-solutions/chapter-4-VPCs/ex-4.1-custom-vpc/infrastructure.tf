terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  profile = "aws_at_sanil_me"
  region  = "ap-south-1"
}

resource "aws_vpc" "main" {
  cidr_block = "192.168.0.0/16"
  tags = {
    "Name": "My First VPC"
  }
}