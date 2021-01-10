terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "ap-south-1"
}

resource "aws_vpc" "first_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "VPC creted from Terraform"
  }
}

resource "aws_subnet" "example_subnet" {
    cidr_block = "10.0.1.0/24"
    vpc_id = aws_vpc.first_vpc.id
    tags = {
      "Name" = "testing_subnet"
    }
  
}