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

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.main.id
  cidr_block = "192.168.1.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    "Name" = "My First Public Subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.main.id
  cidr_block = "192.168.2.0/24"
  availability_zone = "ap-south-1c"
  tags = {
    "Name" = "My First Private Subnet"
  }
}
