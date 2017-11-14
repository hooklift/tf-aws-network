terraform {
  backend "s3" {
    bucket = "hooklift-platform"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
	region = "${var.region}"
}

resource "aws_security_group" "common" {
	name = "common_rules"
	description = "Common rules used across all machines."
	vpc_id = "${aws_vpc.main.id}"

	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	ingress {
		protocol = "icmp"
		from_port = -1
		to_port = -1
		cidr_blocks = ["0.0.0.0/0"]
	}
}

resource "aws_vpc" "main" {
	cidr_block = "${var.vpc_cidr}"
	tags {
		Name = "hooklift"
	}
	enable_dns_support = true
	enable_dns_hostnames = true
}

resource "aws_internet_gateway" "main" {
	vpc_id = "${aws_vpc.main.id}"
}

resource "aws_eip" "nat_gateway" {
	count = "${var.subnets_number}"
	vpc = true
}

// We place a NAT gateway in the public network of each availability zone,
// for private networks to use.
resource "aws_nat_gateway" "gateway" {
	count = "${var.subnets_number}"
	allocation_id = "${element(aws_eip.nat_gateway.*.id, count.index)}"
	subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
	depends_on = ["aws_internet_gateway.main", "aws_eip.nat_gateway"]
}

resource "aws_route_table" "main" {
	vpc_id = "${aws_vpc.main.id}"
	tags {
		Name = "main"
	}
}

// We need to create a routing table per each private subnet in order to
// properly route outgoing internet traffic to each private subnet's NAT gateway.
// This is needed because we can't specify an origin network when creating routing
// rules in AWS.
resource "aws_route_table" "private" {
	count = "${var.subnets_number}"
	vpc_id = "${aws_vpc.main.id}"

	tags {
		Name = "private ${element(aws_subnet.private.*.id, count.index)}, 0.0.0.0/0 ⇢ ${element(aws_nat_gateway.gateway.*.id, count.index)}"
	}
}

// Allows public subnets to use the internet gateway.
resource "aws_route" "public" {
	route_table_id = "${aws_route_table.main.id}"
	destination_cidr_block = "0.0.0.0/0"
	gateway_id = "${aws_internet_gateway.main.id}"
}

// Allows private subnets to reach their NAT gateway for outgoing internet
// traffic.
resource "aws_route" "nat" {
	count = "${var.subnets_number}"
	route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = "${element(aws_nat_gateway.gateway.*.id, count.index)}"
}

// Associates VPC to main routing table.
resource "aws_main_route_table_association" "vpc-main-route-table" {
	vpc_id = "${aws_vpc.main.id}"
	route_table_id = "${aws_route_table.main.id}"
}

resource "aws_subnet" "public" {
	count = "${var.subnets_number}"
	vpc_id = "${aws_vpc.main.id}"
	cidr_block = "${element(split(",", var.public_cidr), count.index)}"
	availability_zone = "${element(split(",", var.zones), count.index)}"
	map_public_ip_on_launch = true

	tags {
		Name = "public-zone-${count.index+1}"
	}

	lifecycle {
		create_before_destroy = true
	}
}

resource "aws_subnet" "private" {
	count = "${var.subnets_number}"
	vpc_id = "${aws_vpc.main.id}"
	cidr_block = "${element(split(",", var.private_cidr), count.index)}"
	availability_zone = "${element(split(",", var.zones), count.index)}"
	map_public_ip_on_launch = false

	tags {
		Name = "private-zone-${count.index+1}"
	}

	lifecycle {
		create_before_destroy = true
	}
}

// Associates public subnets to main routing table.
resource "aws_route_table_association" "public" {
	count = "${var.subnets_number}"
	subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
	route_table_id = "${aws_route_table.main.id}"
}

// Associates private subnets to private routing tables. Remember, there is
// a subnet per availability zone, and a NAT gateway has to be created per
// each public subnet in order to have high availability. Each private subnet
// in each availability zone will have its own NAT gateway. So, here, we are
// basically associating each private routing table to each private subnet.
// A routing table per private subnet is required in order to foward outgoing
// internet traffic from private subnets to their correspondent NAT gateway,
// since we can't specify the origin network in AWS routing rules.
resource "aws_route_table_association" "private" {
	count = "${var.subnets_number}"
	subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
	route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}
