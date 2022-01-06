data "aws_availability_zones" "available" {}

resource "random_shuffle" "az_list" {
  input        = data.aws_availability_zones.available.names
  result_count = var.max_subnets
}

resource "aws_vpc" "atul_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "atul_vpc_${var.env_code}"
  }
}

resource "aws_subnet" "atul_public_subnet" {
  count = var.public_sn_count

  vpc_id                  = aws_vpc.atul_vpc.id
  cidr_block              = var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = random_shuffle.az_list.result[count.index]

  tags = {
    Name = "atul_public_${count.index + 1}_${var.env_code}"
  }
}

resource "aws_route_table_association" "atul_public_association" {
  count = var.public_sn_count

  subnet_id      = aws_subnet.atul_public_subnet.*.id[count.index]
  route_table_id = aws_route_table.atul_public_rt.id
}


resource "aws_subnet" "atul_private_subnet" {
  count = var.private_sn_count

  vpc_id                  = aws_vpc.atul_vpc.id
  cidr_block              = var.private_cidrs[count.index]
  map_public_ip_on_launch = false
  availability_zone       = random_shuffle.az_list.result[count.index]

  tags = {
    Name = "atul_private_${count.index + 1}_${var.env_code}"
  }
}

resource "aws_internet_gateway" "atul_internet_gateway" {
  vpc_id = aws_vpc.atul_vpc.id

  tags = {
    Name = "atul_igw_${var.env_code}"
  }
}

resource "aws_route_table" "atul_public_rt" {
  vpc_id = aws_vpc.atul_vpc.id

  tags = {
    Name = "atul__${var.env_code}"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.atul_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.atul_internet_gateway.id

}

resource "aws_default_route_table" "atul_private_rt" {
  default_route_table_id = aws_vpc.atul_vpc.default_route_table_id

  tags = {
    Name = "atul__${var.env_code}"
  }
}

resource "aws_eip" "atul_nat" {
  count = var.private_sn_count

  vpc = true
}

resource "aws_nat_gateway" "atul_ngw" {
  count = var.private_sn_count

  allocation_id = aws_eip.atul_nat.*.id[count.index]
  subnet_id     = aws_subnet.atul_public_subnet.*.id[count.index]

  tags = {
    Name = "atul_private_${count.index + 1}_${var.env_code}"
  }
}

resource "aws_route_table" "atul_private_route_table" {
  count = var.private_sn_count

  vpc_id = aws_vpc.atul_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.atul_ngw.*.id[count.index]
  }

  tags = {
    Name = "atul_private_${count.index + 1}_${var.env_code}"
  }
}

resource "aws_route_table_association" "atul_route_table_association" {
  count = var.private_sn_count

  subnet_id      = aws_subnet.atul_private_subnet.*.id[count.index]
  route_table_id = aws_route_table.atul_private_route_table.*.id[count.index]
}
