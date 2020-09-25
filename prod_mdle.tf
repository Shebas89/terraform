# component-env-region-whatever (how we need to put the name)
provider "aws" {
    profile = "default"
    region = var.region
}

# VPC
resource "aws_vpc" "prod_mdle_vpc" { 
    cidr_block  = var.vpc_cidr_block
    enable_dns_support   = true
    enable_dns_hostnames = true

    tags = {
        Name = "prod_mdle"
        "Terraform" : "true"
    }
}

# Internet gateway
resource "aws_internet_gateway" "prod_mdle_igw" {
    vpc_id = aws_vpc.prod_mdle_vpc.id

    tags = {
        Name = "IG created by terraform"
        "Terraform" : "true"
    }

}

# Nat IG
resource "aws_nat_gateway" "prod_mdle_nw" {
    depends_on = [aws_internet_gateway.prod_mdle_igw]

    count = length(var.az_private)

    allocation_id = aws_eip.prod_mdle_eip_nw[count.index].id
    subnet_id     = aws_subnet.prod_mdle_az_private[count.index].id
}

# Public Subnet
resource "aws_subnet" "prod_mdle_az_public" {
    count = length(var.cidr_block_az_public)

    vpc_id              = aws_vpc.prod_mdle_vpc.id
    cidr_block          = var.cidr_block_az_public[count.index]
    availability_zone   = var.az_public[count.index]
    tags = {
        Name = "public_sn"
        "Terraform" : "true"
    }
}

# Private Subnet
resource "aws_subnet" "prod_mdle_az_private"{
    count = length(var.cidr_block_az_private)

    vpc_id              = aws_vpc.prod_mdle_vpc.id
    cidr_block          = var.cidr_block_az_private[count.index]
    availability_zone   = var.az_private[count.index]

    tags = {
        Name = "privates_sn"
        "Terraform" : "true"
    }
}

# Public Route
resource "aws_route" "prod_mdle_public_r" {
    route_table_id         = aws_route_table.prod_mdle_public_rt.id
    gateway_id              = aws_internet_gateway.prod_mdle_igw.id
    destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "prod_mdle_public_rt" {
    vpc_id = aws_vpc.prod_mdle_vpc.id

    tags = {
        Name = "Public RT"
        "Terraform" : "true"
    }
}

# Private Route
resource "aws_route" "prod_mdle_private_r" {
    count = length(var.az_private)

    route_table_id         = aws_route_table.prod_mdle_private_rt[count.index].id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id         = aws_nat_gateway.prod_mdle_nw[count.index].id
}

resource "aws_route_table" "prod_mdle_private_rt" {
    count = length(var.az_private)
    
    vpc_id = aws_vpc.prod_mdle_vpc.id

    tags = {
        Name = "Private RT"
        "Terraform" : "true"
    }
}

resource "aws_route_table_association" "prod_mdle_private_rta" {
    count = length(var.cidr_block_az_private)

    subnet_id         = aws_subnet.prod_mdle_az_public[count.index].id
    route_table_id    = aws_route_table.prod_mdle_public_rt.id
}

resource "aws_route_table_association" "prod_mdle_public_rta" {
    count = length(var.cidr_block_az_public)

    subnet_id         = aws_subnet.prod_mdle_az_private[count.index].id
    route_table_id    = aws_route_table.prod_mdle_private_rt[count.index].id 
}

# NACLs of vpc
resource "aws_network_acl" "prod_mdle_nacl" {
    vpc_id = aws_vpc.prod_mdle_vpc.id

    ingress {
        protocol    = "tcp"
        rule_no     = 200
        action      = "allow"
        cidr_block  = "0.0.0.0/0"
        from_port   = 443
        to_port     = 443
    }

    tags = {
        "terraform" : "true"
    }
}

# S3 Bucket
resource "aws_s3_bucket" "prod_mdle_s3"{ 
    bucket  = "prod-mdle-west2-shebas" 
    acl     = "private" # politic of the bucket
}

# Security group
resource "aws_security_group" "prod_mdle_sg" {
    name        = "prod_web"
    description = "Allow http and https ports"
    vpc_id      = aws_vpc.prod_mdle_vpc.id

    ingress {
        from_port   = 80
        to_port     = 80
        protocol     = "tcp"
        cidr_blocks = var.cidr_block_l0
    }
    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = var.cidr_block_l0
    }
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = var.cidr_block_l0
    }
    egress {
        from_port   = 0 # no restrictions
        to_port     = 0 
        protocol     = "-1" # enabled all protocols 
        cidr_blocks = var.cidr_block_l0 
    }

    tags = {
        Name        = "Security Group Mdle"
        "terraform" : "true"
    }
}

#private instance
resource "aws_instance" "prod_mdle_ec2_private" {
    count   = length(var.az_public)

    ami               = "ami-062ca315b459c9e61" # "ami-02f3e801651bd39bc" 
    instance_type     = "t2.micro"
    availability_zone = aws_subnet.prod_mdle_az_private[count.index].availability_zone
    subnet_id         = aws_subnet.prod_mdle_az_private[count.index].id

    vpc_security_group_ids = [
        aws_security_group.prod_mdle_sg.id
    ]

    tags = {
        Name        = "Prod_mdle"
        "Terraform" : "true"
    }
} 

# public instance 
resource "aws_instance" "prod_mdle_ec2_public" {
    ami               = "ami-062ca315b459c9e61"
    instance_type     = "t2.micro"
    availability_zone = aws_subnet.prod_mdle_az_public.0.availability_zone
    subnet_id         = aws_subnet.prod_mdle_az_public.0.id

    vpc_security_group_ids = [
        aws_security_group.prod_mdle_sg.id
    ]

    tags = {
        Name        = "ssh_mdle"
        "Terraform" : "true"
    }
}

# Elastic IP for instances
resource "aws_eip_association" "prod_mdle_eipa_instance" {
    instance_id     = aws_instance.prod_mdle_ec2_public.id
    allocation_id   = aws_eip.prod_mdle_eip_i.id
}

# Elastic IP for Nat gateway
resource "aws_eip" "prod_mdle_eip_nw" {
    count = 2

    vpc  = true
    tags = {
        "Terraform" : "true"
    }
}

resource "aws_eip" "prod_mdle_eip_i" {
    vpc  = true
    
    tags = {
        "Terraform" : "true"
    }
}

# Load Balancer
resource "aws_elb" "prod_mdle_elb" {
    name            = "prod-mdle"
    instances       = aws_instance.prod_mdle_ec2_private.*.id
    subnets         = [ aws_subnet.prod_mdle_az_private.0.id, aws_subnet.prod_mdle_az_private.1.id ]
    security_groups = [ aws_security_group.prod_mdle_sg.id ]
    
    listener {
        instance_port       = 80
        instance_protocol   = "http"
        lb_port             = 80
        lb_protocol         = "http"
    }
    # listener {
    #     instance_port       = 80
    #     instance_protocol   = "http"
    #     lb_port             = 443
    #     lb_protocol         = "https"
    # }

    tags = {
        "Terraform" : "true"
    }
}