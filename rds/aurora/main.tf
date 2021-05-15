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

# Provision RDS aurora cluter
# Enable multi AZ
# Connect to different endpoints 

resource "aws_rds_cluster" "aurora_db" {
  engine = "aurora-postgresql"
  database_name = "mydb"
  master_username = "sanil"
  master_password = "rootroot"
}

output "rds_cluster_members" {
  value = aws_rds_cluster.aurora_db.cluster_members
}

output "endpoint" {
  value = aws_rds_cluster.aurora_db.endpoint
}

output "reader_endpoint" {
  value = aws_rds_cluster.aurora_db.reader_endpoint
}