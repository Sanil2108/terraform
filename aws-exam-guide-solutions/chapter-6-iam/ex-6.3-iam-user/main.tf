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

resource "aws_iam_group" "administrators" {
  name = "administrators"
  path = "/"
}

resource "aws_iam__group_policy_attachment" "attachment" {
  group = aws_iam_group.administrators.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

resource "aws_iam_user" "admin_user" {
  name = "admin"
  path = "/"
}