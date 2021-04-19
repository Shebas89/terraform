# Internet gateway
resource "aws_internet_gateway" "internet_gate_way" {
    vpc_id = var.vpc_id

    tags = {
        Name = "IG created by terraform"
        "Terraform" : "true"
    }

}

# Nat IG
resource "aws_nat_gateway" "nat_gateway" {
    depends_on = [aws_internet_gateway.internet_gate_way]

    count = length(var.private_subnets)

    allocation_id = aws_eip.eip_nw[count.index].id
    subnet_id     = var.private_subnets[count.index].id

    tags = {
        Name = "Nats Gateway prod_mdle"
        "Terraform" : "true"
    }
}
# Public Subnet
resource "aws_subnet" "subnet_public" {
    vpc_id              = var.vpc_id
    cidr_block          = var.cidr_block
    availability_zone   = var.public_subnets
    tags = {
        Name = "public_sn"
        "Terraform" : "true"
    }
}

# Private Subnet
resource "aws_subnet" "subnet_private"{
    count = length(var.private_subnets)

    vpc_id              = var.vpc_id
    cidr_block          = var.cidr_block_az_private[count.index]
    availability_zone   = var.private_subnets[count.index]

    tags = {
        Name = "privates_sn"
        "Terraform" : "true"
    }
}


# Public Route
resource "aws_route" "public_route" {
    route_table_id         = aws_route_table.public_route_table.id
    gateway_id             = aws_internet_gateway.internet_gate_way.id
    destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "public_route_table" {
    vpc_id = var.vpc_id

    tags = {
        Name = "Public RT"
        "Terraform" : "true"
    }
}

# Private Route
resource "aws_route" "private_route_table" {
    count = length(var.private_subnets)

    route_table_id         = aws_route_table.private_route_table[count.index].id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id         = aws_nat_gateway.nat_gateway[count.index].id
}

resource "aws_route_table" "private_route_table" {
    count = length(var.az_private)
    
    vpc_id = var.vpc_id

    tags = {
        Name = "Private RT"
        "Terraform" : "true"
    }
}

resource "aws_route_table_association" "private_rt_association" {
    count = length(var.cidr_block_az_private)

    subnet_id         = aws_subnet.subnet_private[count.index].id
    route_table_id    = aws_route_table.private_route_table[count.index].id
}

resource "aws_route_table_association" "public_rt_association" {
    subnet_id         = aws_subnet.public_subnets.id
    route_table_id    = aws_route_table.public_route_table.id 
}

# NACLs of vpc
resource "aws_network_acl" "network_acl" {
    vpc_id = var.vpc_id

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

# Elastic IP for Nat gateway
resource "aws_eip" "eip_nw" {
    count = 2

    vpc  = true
    tags = {
        "Terraform" : "true"
    }
}
