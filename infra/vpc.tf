// Base VPC Networking  ↓↓↓
data "aws_availability_zones" "available" {}

resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name                                        = "${var.project_name}-vpc",
    CreatedBy                                   = "terraform",
    "kubernetes.io/cluster/${var.project_name}" = "shared",
  }
}

resource "aws_subnet" "eks_subnet" {
  count                   = length(var.public_subnets)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = cidrsubnet(aws_vpc.eks_vpc.cidr_block, 4, count.index)
  vpc_id                  = aws_vpc.eks_vpc.id
  map_public_ip_on_launch = true
  tags = {
    Name                                        = "${var.project_name}-vpc-subnet-${data.aws_availability_zones.available.names[count.index]}",
    CreatedBy                                   = "terraform",
    "kubernetes.io/cluster/${var.project_name}" = "shared",
  }
}


resource "aws_internet_gateway" "eks_vpc_internet_gateway" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = {
    Name      = "${var.project_name}-vpc-ig"
    CreatedBy = "terraform"
  }
}

resource "aws_route_table" "eks_vpc_route_table" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_vpc_internet_gateway.id
  }
  tags = {
    CreatedBy = "terraform"
  }
}

resource "aws_route_table_association" "eks_vpc_route_table_association" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.eks_subnet.*.id[count.index]
  route_table_id = aws_route_table.eks_vpc_route_table.id
}
