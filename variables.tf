variable "vpc_cidr" {
	description = "VPC IP address range."
}

variable "subnets_number" {
	description = "Number of subnets to use, one per availability zone."
}

variable "public_cidr" {
	description = "List of public IP ranges for the different availability zones"
}

variable "private_cidr" {
	description = "List of private IP ranges for cell nodes in the different availability zones."
}

variable "zones" {
	description = "Comma-separated list of availability zones to use."
}

variable "region" {
	description = "The region of AWS where operations will take place."
}
