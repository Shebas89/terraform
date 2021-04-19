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

    tags = {
        Name = "Nats Gateway prod_mdle"
        "Terraform" : "true"
    }
}
# Public Subnet
resource "aws_subnet" "prod_mdle_az_public" {
    vpc_id              = aws_vpc.prod_mdle_vpc.id
    cidr_block          = var.cidr_block_az_public
    availability_zone   = var.az_public
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

    subnet_id         = aws_subnet.prod_mdle_az_private[count.index].id
    route_table_id    = aws_route_table.prod_mdle_private_rt[count.index].id
}

resource "aws_route_table_association" "prod_mdle_public_rta" {
    subnet_id         = aws_subnet.prod_mdle_az_public.id
    route_table_id    = aws_route_table.prod_mdle_public_rt.id 
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
