output "vpc_id" {
  value       = "${aws_vpc.main.id}"
  description = "The VPC ID created"
}

output "vpc_cidr_block" {
  value       = "${aws_vpc.main.cidr_block}"
  description = "CIDR block for the entire VPC"
}

output "public_subnets" {
  value       = ["${aws_subnet.public.*.id}"]
  description = "Public subnets IDs created"
}

output "private_subnets" {
  value       = ["${aws_subnet.private.*.id}"]
  description = "Private subnet IDs created"
}

output "public_cidr_blocks" {
  value       = ["${aws_subnet.public.*.cidr_block}"]
  description = "Public CIDR blocks"
}

output "private_cidr_blocks" {
  value       = ["${aws_subnet.private.*.cidr_block}"]
  description = "Private CIDR blocks"
}
