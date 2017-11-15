variable "vpc_cidr" {
  type        = "string"
  description = "VPC's CIDR block"
}

variable "vpc_dns_support" {
  type        = "string"
  description = "Whether to enable or disable VPC DNS support"
  default     = "true"
}

variable "vpc_dns_hostnames" {
  type        = "string"
  description = "Whether to enable or disable VPC DNS support for host names"
  default     = "true"
}

variable "public_subnets" {
  type        = "list"
  description = "List of public subnets for the different availability zones, in CIDR format."
  default     = []
}

variable "private_subnets" {
  type        = "list"
  description = "List of private subnets for the different availability zones, in CIDR format."
  default     = []
}

variable "zones" {
  type        = "list"
  description = "List of availability zones to use."
  default     = []
}
