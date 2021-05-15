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

# Provision a RDS instance
# Enable Multi AZ

resource "aws_db_instance" "default" {
  allocated_storage = 10

  engine = "postgres"
  engine_version = "10.4"

  instance_class = "db.t3.micro"

  name = "mydb"
  username = "sanil"
  password = "rootroot"

  multi_az = true
}