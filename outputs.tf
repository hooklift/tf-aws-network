output "vpc_id" {
	value = "${aws_vpc.main.id}"
}

output "vpc_cidr_block" {
	value = "${aws_vpc.main.cidr_block}"
}

output "public_subnets" {
	value = ["${aws_subnet.public.*.id}"]
}

output "private_subnets" {
	value = ["${aws_subnet.private.*.id}"]
}

output "public_cidr_blocks" {
	value = ["${aws_subnet.public.*.cidr_block}"]
}

output "private_cidr_blocks" {
	value = ["${aws_subnet.private.*.cidr_block}"]
}

output "common_security_group_id" {
	value = "${aws_security_group.common.id}"
}


