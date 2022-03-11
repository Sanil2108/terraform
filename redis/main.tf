provider "aws" {
  region = "ap-south-1"
}

module "single-public-subnet" {
  source = "../modules/single-public-subnet"
}

module "ec2-instance" {
  source = "../modules/ec2-instance"

  user_data = file("./server-userdata.sh")
  subnet_id = module.single-public-subnet.subnet_id
  vpc_id = module.single-public-subnet.vpc_id
}