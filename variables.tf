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
    default     = ["172.32.1.0/24", "172.32.2.0/24"]
    type        = list
    description = "CIDR blocks for subnet private"
}

variable "cidr_block_az_public" {
    default     = "172.32.0.0/24"
    type        = string
    description = "CIDR blocks for subnet public"
}

variable "cidr_block_l0" {
    default     = ["0.0.0.0/0"]
    type        = list
    description = "CIDR Block for any IP"
}

variable "az_private" {
    default     = ["us-west-2b", "us-west-2c"]
    type        = list(string)
    description = "private AZs"
}

variable "az_public" {
    default     = "us-west-2a"
    type        = string
    description = "public AZs"
}