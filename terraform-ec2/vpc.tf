#VPC
resource "aws_vpc" "mainvpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags = {
    Name = "daromain"
  }
}

#Subnets
resource "aws_subnet" "publicsubnet" {
  vpc_id                  = aws_vpc.mainvpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "mainpublic"
  }
}

#Internet Gateway
resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.mainvpc.id

  tags = {
    Name = "myigw"
  }
}

#Routes Table to IGW
resource "aws_route_table" "igwroute" {
  vpc_id = aws_vpc.mainvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }

  tags = {
    Name = "igwroute"
  }
}

#Route Table Association
resource "aws_route_table_association" "publicsubnetassoc" {
  subnet_id      = aws_subnet.publicsubnet.id
  route_table_id = aws_route_table.igwroute.id
}