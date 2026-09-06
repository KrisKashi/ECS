resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "gatus-vpc"
  }
}

resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet1"
  }
}

resource "aws_subnet" "subnet-2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-west-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet2"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "s1-route" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "s2-route" {
  subnet_id      = aws_subnet.subnet-2.id
  route_table_id = aws_route_table.rt.id
}