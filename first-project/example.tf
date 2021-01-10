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

resource "aws_instance" "example" {
  ami           = "ami-0b44050b2d893d5f7"
  instance_type = "t2.micro"
  tags = {
    "Name" = "testing"
  }
}
