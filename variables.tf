variable "region" {
  default     = "us-west-2"
  type        = string
  description = "Region of the VPC"
}

variable "vpc_cidr_block" {
    default     = "172.32.0.0/16"
    type        = string
    description = "CIDR block for VPC"
}

variable "cidr_block_az_private" {
    default     = ["172.32.0.0/24", "172.32.2.0/24"]
    type        = list
    description = "CIDR blocks for subnet private"
}

variable "cidr_block_az_public" {
    default     = ["172.32.1.0/24", "172.32.3.0/24"]
    type        = list(string)
    description = "CIDR blocks for subnet public"
}

variable "az_public" {
    default     = ["us-west-2a", "us-west-2c"]
    type        = list(string)
    description = "public AZs"
}

variable "az_private" {
    default     = ["us-west-2b", "us-west-2d"]
    type        = list(string)
    description = "private AZs"
}