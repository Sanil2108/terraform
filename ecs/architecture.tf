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

resource "aws_iam_role" "ec2-role" {
  name               = "ec2-ecs-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ec2-role-policy-attachment" {
  role = aws_iam_role.ec2-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ec2-profile" {
  name = "ec2-profile"
  role = aws_iam_role.ec2-role.name
}

resource "aws_launch_template" "main_lt" {
  name_prefix   = "asg_launch_template"
  image_id      = "ami-0b44050b2d893d5f7"
  instance_type = "t2.micro"
  user_data     = ""
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2-profile.name
  }
}

resource "aws_autoscaling_group" "test" {
  name               = "test"
  max_size           = 4
  min_size           = 1
  desired_capacity   = 2
  availability_zones = ["ap-south-1b"]

  launch_template {
    id      = aws_launch_template.main_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }
}

resource "aws_ecs_capacity_provider" "test_provider" {
  name = "test"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.test.arn

    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 10
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
    }
  }
}

resource "aws_ecs_cluster" "main_cluster" {
  name               = "main_cluster"
  depends_on         = [aws_ecs_capacity_provider.test_provider]
  capacity_providers = ["test"]
  default_capacity_provider_strategy {
    capacity_provider = "test"
  }
}
