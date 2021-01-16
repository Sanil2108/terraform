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


resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    tags = {
      "Name" = "main-vpc"
    }
}

resource "aws_subnet" "public" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.0.0/16"
    tags = {
      "Name" = "public subnet"
    }
}

resource "aws_internet_gateway" "main_igw" {
    vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "main_rt" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main_igw.id
    }
}

resource "aws_route_table_association" "public_subnet_association" {
    route_table_id = aws_route_table.main_rt.id
    subnet_id = aws_subnet.public.id
}

resource "aws_security_group" "main_sg" {
    name = "main_sg"
    vpc_id = aws_vpc.main.id

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
    }
}

resource "aws_launch_template" "asg_launch_template" {
    name_prefix = "asg_launch_template"
    image_id = "ami-0b44050b2d893d5f7"
    instance_type = "t2.micro"
    user_data = ""


    network_interfaces {
        subnet_id = aws_subnet.public.id
    }
}

resource "aws_autoscaling_group" "main_asg" {
    name = "main_asg"
    max_size = 6
    min_size = 2
    desired_capacity = 4
    availability_zones = ["ap-south-1a"]

    launch_template {
        id = aws_launch_template.asg_launch_template.id
        version = "$Latest"
    }

    vpc_zone_identifier = [aws_subnet.public.id]
}