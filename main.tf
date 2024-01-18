terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# creating the VPC
resource "aws_vpc" "vpc-1" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  tags = {
    Name = "main"
  }
}

# Subnet 1
resource "aws_subnet" "subnet-1" {
  vpc_id                  = aws_vpc.vpc-1.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "development-server-1"
  }

}

# Subnet 2
resource "aws_subnet" "subnet-2" {
  vpc_id                  = aws_vpc.vpc-1.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "development-server-2"
  }
}

# creating internet gateway
resource "aws_internet_gateway" "igw1" {
  vpc_id = aws_vpc.vpc-1.id
  tags = {
    Name = "IGW-1"
  }
}

# creating the route table
resource "aws_route_table" "RT-1" {
  vpc_id = aws_vpc.vpc-1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw1.id
  }

  tags = {
    Name = "dev-rt"
  }
}

# Route table association
resource "aws_route_table_association" "subnet1" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.RT-1.id
}

# Route table association
resource "aws_route_table_association" "subnet2" {
  subnet_id      = aws_subnet.subnet-2.id
  route_table_id = aws_route_table.RT-1.id
}

# EC2 instances
resource "aws_instance" "public-inst1" {
    ami = "ami-0005e0cfe09cc9050"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.subnet-1.id}"
    tags = {
      name = "public-instance-1"
    }
}
# EC2 instances
resource "aws_instance" "public-inst2" {
    ami = "ami-0005e0cfe09cc9050"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.subnet-2.id}"
    tags = {
      name = "public-instance-2"
    }
}

output "aws_instanceip" {
    value = aws_instance.public-inst1.public_ip
}

output "aws_instanceip2" {
    value = aws_instance.public-inst2
}
