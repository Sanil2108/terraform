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

# Postgres DB (v10.4-R1)
# Single Node (For development)
# Storage: 25GB General Purpose SSD
# Publicly Accessible
# Encrypted at rest
# Backup retention of 5 days, backup window 10PM everyday
# Auto upgrade minor versions, maintenence window at Sunday 11pm

resource "aws_db_instance" "main_db" {
  allocated_storage = 25

  engine = "postgres"
  engine_version = "10.4"

  instance_class = "db.m5.large"

  auto_minor_version_upgrade = true
  maintenance_window = "Sun:23:00-Sun:23:30"

  publicly_accessible = true

  storage_encrypted = true

  backup_retention_period = 5
  backup_window = "20:00-20:30"

  name = "mydb"
  username = "sanil"
  password = "rootroot"
}