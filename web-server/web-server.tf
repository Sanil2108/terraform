# Objective

# 1. Setting up network infrastructure

# 1.1 Setting up a VPC
# 1.2 Setting up a public route table
# 1.3 Setting up a private route table
# 1.4 Setting up 2 public subnets
# 1.5 Setting up 2 private subnets
# 1.6 Setting up an IGW
# 1.7 Setting up a NAT Gateway


# 2. Setting up EC2 Instances
# 2.1 Creating a security group for public EC2 instance
# 2.2 Creating a security group for private EC2 instance
# 2.3 Setting up an EC2 instance on public subnet 1 with elastic IP
# 2.4 Setting up an EC2 instance on private subnet 1

# Code

# Init
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

# 1. Seting up network infra
# 1.1 Creating a VPC
resource "aws_vpc" "main-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "terraform-project-vpc"
  }
}

# 1.2 Setting up a public route table
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.main-vpc.id
  tags = {
    "Name" = "public-route-table"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main-igw.id
  }
  depends_on = [ aws_internet_gateway.main-igw ]
}

# 1.3 Setting up a private route table
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.main-vpc.id
  tags = {
    "Name" = "private-route-table"
  }
}

# 1.4 Setting up 2 public subnets
resource "aws_subnet" "public-subnet-1" {
  vpc_id = aws_vpc.main-vpc.id
  availability_zone = "ap-south-1b"
  cidr_block = "10.0.0.0/18"
  tags = {
    "Name" = "public-subnet-1"
  }
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public-subnet-2" {
  vpc_id = aws_vpc.main-vpc.id
  cidr_block = "10.0.64.0/18"
  availability_zone = "ap-south-1b"
  tags = {
    "Name" = "public-subnet-2"
  }
  map_public_ip_on_launch = true
}

resource "aws_route_table_association" "public-subnet-1-table-association1" {
  subnet_id = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.public-route-table.id
}

resource "aws_route_table_association" "public-subnet-2-table-association1" {
  subnet_id = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.public-route-table.id
}

# 1.5 Setting up 2 private subnets
resource "aws_subnet" "private-subnet-1" {
  vpc_id = aws_vpc.main-vpc.id
  cidr_block = "10.0.128.0/18"
  availability_zone = "ap-south-1b"
  tags = {
    "Name" = "private-subnet-1"
  }
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private-subnet-2" {
  vpc_id = aws_vpc.main-vpc.id
  cidr_block = "10.0.192.0/18"
  availability_zone = "ap-south-1b"
  tags = {
    "Name" = "private-subnet-2"
  }
  map_public_ip_on_launch = true
}

resource "aws_route_table_association" "private-subnet-1-table-association1" {
  subnet_id = aws_subnet.private-subnet-1.id
  route_table_id = aws_route_table.private-route-table.id
}

resource "aws_route_table_association" "private-subnet-2-table-association1" {
  subnet_id = aws_subnet.private-subnet-2.id
  route_table_id = aws_route_table.private-route-table.id
}

# 1.6 Setting up an IGW
resource "aws_internet_gateway" "main-igw" {
  vpc_id = aws_vpc.main-vpc.id
  tags = {
    "Name" = "terraform-project-igw"
  }
}

# 1.7 Setting up a NAT Gateway
# resource "aws_nat_gateway" "nat-gateway" {
#   subnet_id = aws_subnet.public-subnet-1.id
# }



# 2 Setting up EC2 Instances

# 2.1 Creating a security group for public EC2 instance
resource "aws_security_group" "public-ec2-sg" {
  name = "public-security-group"
  vpc_id = aws_vpc.main-vpc.id
  
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    protocol = "tcp"
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2.2 Creating a security group for private EC2 instance
resource "aws_security_group" "private-ec2-sg" {
  name = "private-security-group"
  vpc_id = aws_vpc.main-vpc.id

  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2.3 Setting up an EC2 instance on public subnet 1 with elastic IP
resource "aws_instance" "public-ec2" {
  ami = "ami-0a4a70bd98c6d6441"
  instance_type = "t2.micro"
  tags = {
    "Name" = "public-ec2"
  }
  subnet_id = aws_subnet.public-subnet-1.id
  vpc_security_group_ids = [ aws_security_group.public-ec2-sg.id ]
}

# 2.4 Setting up an EC2 instance on private subnet 1
resource "aws_instance" "private-ec2" {
  ami = "ami-0a4a70bd98c6d6441"
  instance_type = "t2.micro"
  tags = {
    "Name" = "private-ec2"
  }
  subnet_id = aws_subnet.private-subnet-1.id
  vpc_security_group_ids = [ aws_security_group.private-ec2-sg.id ]
}