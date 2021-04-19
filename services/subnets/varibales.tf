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

variable "vpc_cidr_block" {
    default     = "172.32.0.0/16"
    type        = string
    description = "CIDR block for VPC"
}
