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

# Register an application load balancer that balances requests between two EC2 instances

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_default_subnet" "subnet-a" {
  availability_zone = "ap-south-1a"
}

resource "aws_default_subnet" "subnet-b" {
  availability_zone = "ap-south-1b"
}

resource "aws_default_subnet" "subnet-c" {
  availability_zone = "ap-south-1c"
}


resource "aws_security_group" "main-sg" {
  name = "main-sg"
  vpc_id = aws_default_vpc.default.id

  egress {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    protocol = "-1"
    to_port = 0
  }

  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 22
    protocol = "tcp"
    to_port = 22
  }

  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 443
    protocol = "tcp"
    to_port = 443
  }

  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 80
    protocol = "tcp"
    to_port = 80
  }
}


resource "aws_lb" "main-lb" {
  name = "main-lb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.main-sg.id]
  subnets = [
    aws_default_subnet.subnet-a.id,
    aws_default_subnet.subnet-b.id,
  ]

  tags = {
    "Name" = "Mian LB"
  }
}

resource "aws_lb_listener" "main-listener" {
  load_balancer_arn = aws_lb.main-lb.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.main-lb-tg.arn
  }
}

resource "aws_lb_target_group" "main-lb-tg" {
  name = "tg"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_default_vpc.default.id
}

resource "aws_launch_template" "lt" {
  vpc_security_group_ids = [aws_security_group.main-sg.id]
  user_data = base64encode(file("./user-data.sh"))
  image_id =  "ami-0c1a7f89451184c8b"
  instance_type = "t2.micro"
  key_name = "main-key-pair"

}

resource "aws_autoscaling_group" "asg" {
  max_size = 5
  min_size = 2
  health_check_type = "ELB"
  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.main-lb-tg.arn]
  availability_zones = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}