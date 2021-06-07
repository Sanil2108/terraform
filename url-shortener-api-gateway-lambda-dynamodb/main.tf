terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.44.0"
    }
  }
}

provider "aws" {
  profile = "aws_at_sanil_me"
  region  = "ap-south-1"
}

# DynamoDB table
resource "aws_dynamodb_table" "shorturls_table" {
  name = "ShortURLs"
  hash_key = "id"
  read_capacity  = 10
  write_capacity = 10

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_dynamodb_table_item" "initial_item" {
  table_name = aws_dynamodb_table.shorturls_table.name
  hash_key = aws_dynamodb_table.shorturls_table.hash_key

  item = <<ITEM
{
  "id": {"S": "988f1042-9a8c-4983-b855-27f02db3b15b"},
  "shortUrl": {"S": "testing"},
  "url": {"S": "google.com"},
  "timestamp": {"N": "1622936989"}
}
ITEM
}

# AWS IAM roles, policies, etc.
resource "aws_iam_role_policy" "create_short_url_role_policy" {
  name = "CreateShortURLRolePolicy"
  role = aws_iam_role.create_short_url_role.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "Stmt1622933672234",
        "Action": [
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:PutItem"
        ],
        "Effect": "Allow",
        "Resource": aws_dynamodb_table.shorturls_table.arn
      }
    ]
  })
}

resource "aws_iam_role" "create_short_url_role" {
  name = "CreateShortURLRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# API Gateway
resource "aws_api_gateway_rest_api" "api_gateway" {
  name = "URL Shortener API Gateway"
}

resource "aws_api_gateway_resource" "main_rest_api" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part = "create_url"
}

resource "aws_api_gateway_method" "create_short_url" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.main_rest_api.id
  http_method = "POST"
  authorization = "NONE"
}

# ECR repositories
resource "aws_ecr_repository" "url_shortening_images_repository_create" {
  name = "url_shortening_repository_create"
}

resource "aws_ecr_repository" "url_shortening_images_repository_get" {
  name = "url_shortening_repository_get"
}

resource "aws_ecr_repository" "url_shortening_images_repository_check" {
  name = "url_shortening_repository_check"
}

# Lambda functions
resource "aws_lambda_function" "create_url_function" {
  role          = aws_iam_role.create_short_url_role.arn
  function_name = "CreateURL"
  image_uri = "067237244850.dkr.ecr.ap-south-1.amazonaws.com/url_shortening_repository_create:latest"
  package_type = "Image"
  runtime = "python3.8"
}

resource "aws_lambda_function" "check_url_function" {
  role          = aws_iam_role.create_short_url_role.arn
  function_name = "CheckURL"
  image_uri = "067237244850.dkr.ecr.ap-south-1.amazonaws.com/url_shortening_repository_check:latest"
  package_type = "Image"
  runtime = "python3.8"
}

resource "aws_lambda_function" "get_url_function" {
  role          = aws_iam_role.create_short_url_role.arn
  function_name = "GetURL"
  image_uri = "067237244850.dkr.ecr.ap-south-1.amazonaws.com/url_shortening_repository_get:latest"
  package_type = "Image"
  runtime = "python3.8"
}