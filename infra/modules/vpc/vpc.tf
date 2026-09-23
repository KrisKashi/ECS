resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"
  tags = {
    Name = "gatus-vpc"
  }
}
## new combined subnet
locals {
  availability_zones = ["eu-west-2a", "eu-west-2b"]
}

resource "aws_subnet" "subnet" { ## Public subnets 
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, count.index + 1)
  availability_zone = local.availability_zones[count.index]

  tags = {
    Name = "subnet.${count.index + 1}"
  }
}

resource "aws_subnet" "subnet_priv" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, count.index + 5)
  availability_zone = local.availability_zones[count.index]

  tags = {
    Name = "subnet_priv.${count.index + 1}"
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

resource "aws_route_table" "rt_nat" {
  count  = 2
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }
}

resource "aws_route_table_association" "public_subnets" {
  count          = 2
  subnet_id      = aws_subnet.subnet[count.index].id
  route_table_id = aws_route_table.rt.id

}

resource "aws_route_table_association" "private_subnets" {
  count          = 2
  subnet_id      = aws_subnet.subnet_priv[count.index].id
  route_table_id = aws_route_table.rt_nat[count.index].id
}

resource "aws_eip" "nat_ip" {
  count  = 2
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  count         = 2
  allocation_id = aws_eip.nat_ip[count.index].id
  subnet_id     = aws_subnet.subnet[count.index].id

  tags = {
    Name = "gw NAT"
  }

  depends_on = [aws_internet_gateway.gw]
}