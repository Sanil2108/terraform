terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.44"
    }
  }
}

provider "aws" {
  profile = "aws_at_sanil_me"
  region  = "ap-south-1"
}

resource "aws_dynamodb_table" "pets" {
  name = "PetInventory"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key = "pet_species"
  range_key = "pet_id"

  attribute {
    name = "pet_species"
    type = "S"
  }

  attribute {
    name = "pet_id"
    type = "N"
  }

}
