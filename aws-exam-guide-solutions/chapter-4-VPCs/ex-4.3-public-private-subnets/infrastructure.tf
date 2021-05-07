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

resource "aws_vpc" "main" {
  cidr_block = "192.168.0.0/16"
  tags = {
    "Name": "My First VPC"
  }
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "My First IGW"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.main.id
  cidr_block = "192.168.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-south-1b"
  tags = {
    "Name" = "My First Public Subnet"
  }
}

resource "aws_route_table_association" "public_association" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.main.id
  cidr_block = "192.168.2.0/24"
  availability_zone = "ap-south-1c"
  tags = {
    "Name" = "My First Private Subnet"
  }
}

resource "aws_key_pair" "kp" {
  key_name = "key_for_chapter_4_ex"
  public_key = ""
}

resource "aws_security_group" "sg" {
  name        = "Chapter 4 Exercises"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Chapter 4 Exercises"
  }
}

resource "aws_instance" "instance" {
  ami = "ami-045e6fa7127ab1ac4"
  instance_type = "t2.micro"
  key_name = "key_for_chapter_4_ex"
  subnet_id = aws_subnet.public_subnet.id
  tags = {
    "Name" = "My first instance"
  }
  vpc_security_group_ids = [ aws_security_group.sg.id ]
  associate_public_ip_address = true
}

output "instance_ip_addr" {
  value = aws_instance.instance.public_ip
}