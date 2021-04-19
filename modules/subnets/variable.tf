variable "vpc_id"{
    type = string
}

variable "private_subnets" {
    default = []
    type    = list
}

variable "public_subnets" {
    default = []
    type    = list
}

variable "cidr_block_az_private" {
    type = list
}