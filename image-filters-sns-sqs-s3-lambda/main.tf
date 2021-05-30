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


resource "aws_s3_bucket" "output_bucket" {
  bucket = "sanil-khurana-image-filters-output-bucket"

  tags = {
    Name = "Image Filters Output Bucket"
  }
}

resource "aws_sns_topic" "main_topic" {
  name = "image-filters-topic"
}

resource "aws_iam_policy" "iam_policy" {
  name        = "image_filters_iam_policy_for_lambda"
  path        = "/"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "Stmt1622336124866",
        "Action": [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        "Effect": "Allow",
        "Resource": "*"
      },
      {
        "Sid": "Stmt1622337537568",
        "Action": [
          "s3:PutObject"
        ],
        "Effect": "Allow",
        "Resource": aws_s3_bucket.output_bucket.arn
      }
    ]
  })
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "ImageFiltersIAMForLambda"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "iam_policy_attachment" {
  role = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.iam_policy.arn
}

resource "aws_iam_role_policy_attachment" "execution_role_attachment" {
  role = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


resource "aws_sqs_queue" "bw_queue" {
  name = "imae-filters-bw-queue"
  delay_seconds = 0
  policy = jsonencode({
    "Statement": [{
      "Effect":"Allow",
      "Principal": {
        "Service": "sns.amazonaws.com"
      },
      "Action":"sqs:SendMessage",
      "Resource":"arn:aws:sqs:us-east-2:123456789012:MyQueue",
      "Condition":{
        "ArnEquals":{
          "aws:SourceArn":"arn:aws:sns:us-east-2:123456789012:MyTopic"
        }
      }
    }]
  })
}

resource "aws_sqs_queue_policy" "test" {
  queue_url = aws_sqs_queue.bw_queue.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.bw_queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.main_topic.arn}"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_sns_topic_subscription" "bw_queue_sns_subscription" {
  protocol = "sqs"
  topic_arn = aws_sns_topic.main_topic.arn
  endpoint = aws_sqs_queue.bw_queue.arn
}

resource "aws_lambda_function" "bw_function" {
  function_name = "image_filters_bw_function"
  role = aws_iam_role.iam_for_lambda.arn
  runtime = "python3.6"
  handler = "lambda_function.lambda_handler"
  filename = "black_white_function.zip"
}

resource "aws_lambda_event_source_mapping" "bw_function_event_source" {
  event_source_arn = aws_sqs_queue.bw_queue.arn
  function_name    = aws_lambda_function.bw_function.arn
}