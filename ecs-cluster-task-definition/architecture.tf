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

# IAM

resource "aws_iam_role" "ec2_role_for_ecs" {
  name               = "ec2_role_for_ecs"
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

resource "aws_iam_role_policy_attachment" "ec2_ecs_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  role       = aws_iam_role.ec2_role_for_ecs.name
}

resource "aws_iam_instance_profile" "ec2_instance_profile_for_ecs" {
  name = "ec2_instance_profile_for_ecs_7"
  role = aws_iam_role.ec2_role_for_ecs.name
}

# Launch template

resource "aws_launch_template" "ec2_launch_template" {
  image_id      = "ami-0a4a70bd98c6d6441"
  instance_type = "t2.micro"
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile_for_ecs.name
  }
}

# Setting up the ASG

resource "aws_autoscaling_group" "ec2_asg" {
  name               = "terraform_asg"
  max_size           = 4
  min_size           = 1
  desired_capacity   = 2
  availability_zones = ["ap-south-1b"]

  launch_template {
    id      = aws_launch_template.ec2_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }
}

# Setting up ECS Capacity Provider

resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
  name = "test_capacity_provider_7"
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ec2_asg.arn

    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 10
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
    }
  }
}

# Setting up ECS Cluster

resource "aws_ecs_cluster" "main_cluster" {
  name               = "main_cluster"
  depends_on = [ aws_ecs_capacity_provider.ecs_capacity_provider ]
  capacity_providers = [aws_ecs_capacity_provider.ecs_capacity_provider.name]
  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
    weight            = 100
  }
}

# Specifying a task definition

resource "aws_ecs_task_definition" "web_service_task_definition" {
  family = "web_service"
  container_definitions = file("task_definitions/web-service.json")
}

# Run the task

resource "aws_ecs_service" "web_service" {
  task_definition = aws_ecs_task_definition.web_service_task_definition.arn
  name = "web_service"
  cluster = aws_ecs_cluster.main_cluster.id
  desired_count = 2
  depends_on = [ aws_iam_role.ec2_role_for_ecs ]
}



