resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = var.vpc_tenancy
  enable_dns_support   = var.vpc_dns_support
  enable_dns_hostnames = var.vpc_dns_hostnames
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

// Each NAT Gateway needs an Elastic IP Address that is used as source IP
// when forwarding traffic to the internet gateway.
resource "aws_eip" "nat_gateway" {
  count = length(var.public_subnets)
  vpc   = true
}

// We place a NAT gateway in the public network of each availability zone,
// for private networks to use.
resource "aws_nat_gateway" "gateway" {
  count         = length(var.public_subnets)
  allocation_id = aws_eip.nat_gateway.*.id[count.index]
  subnet_id     = aws_subnet.public.*.id[count.index]
  depends_on    = [aws_internet_gateway.main, aws_eip.nat_gateway]
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

// We need to create a routing table per each private subnet in order to
// properly route outgoing internet traffic to each private subnet's NAT gateway.
// This is needed because we can't specify an origin network when creating routing
// rules in AWS.
resource "aws_route_table" "private" {
  count  = length(var.private_subnets)
  vpc_id = aws_vpc.main.id
}

// Allows public subnets to use the internet gateway.
resource "aws_route" "public" {
  route_table_id         = aws_route_table.main.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

// Allows private subnets to reach their NAT gateway for outgoing internet
// traffic.
resource "aws_route" "nat" {
  count                  = length(var.private_subnets)
  route_table_id         = aws_route_table.private.*.id[count.index]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.gateway.*.id, count.index)
}

// Associates VPC to main routing table.
resource "aws_main_route_table_association" "vpc-main-route-table" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.main.id
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = element(var.zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "public-zone-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count                   = length(var.private_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnets[count.index]
  availability_zone       = element(var.zones, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "private-zone-${count.index + 1}"
  }
}

// Associates public subnets to main routing table.
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.main.id
}

// Associates private subnets to private routing tables. Remember, there is
// a subnet per availability zone, and a NAT gateway has to be created per
// each public subnet in order to have high availability. Each private subnet
// in each availability zone will have its own NAT gateway too. So, here, we are
// basically associating each private routing table to each private subnet.
// A routing table per private subnet is required in order to foward outgoing
// internet traffic from private subnets to their correspondent NAT gateway,
// since we can't specify the origin network in AWS routing rules.
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private.*.id[count.index]
  route_table_id = aws_route_table.private.*.id[count.index]
}
