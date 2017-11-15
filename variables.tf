variable "vpc_cidr" {
  type        = "string"
  description = "VPC's CIDR block"
  default     = "10.0.0.0/16"
}

variable "vpc_tenancy" {
  type        = "string"
  description = "VPC instance tenancy: dedicated, default or host"
  default     = "default"
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
  default     = ["10.0.32.0/20", "10.0.96.0/20", "10.0.160.0/20"]
}

variable "private_subnets" {
  type        = "list"
  description = "List of private subnets for the different availability zones, in CIDR format."
  default     = ["10.0.0.0/19", "10.0.64.0/19", "10.0.128.0/19"]
}

variable "zones" {
  type        = "list"
  description = "List of availability zones to use."
  default     = ["us-east-1a", "us-east-1e", "us-east-1c"]
}
