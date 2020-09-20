# component-env-region-whatever (how we need to put the name)
provider "aws" {
    profile = "default"
    region = "us-west-2"
}

resource "aws_s3_bucket" "prod_mdle_s3"{ # type of the resource and the name of the resource (name is for tf)
    bucket  = "prod-mdle-west2-shebas" # name of the bucket
    acl     = "private" # po litic of the bucket
}

resource "aws_default_vpc" "default" {
    tags = {
        Name = "Default VPC (Terraform)"
    }
}

resource "aws_default_subnet" "default_az1" {
    availability_zone   = "us-west-2a"
    tags = {
        "Terraform" : "true"
    }
}

resource "aws_default_subnet" "default_az2"{
    availability_zone   = "us-west-2b"
    tags = {
        "Terraform" : "true"
    }
}

/*resource "aws_internet_gateway" "prod_mdle_igw"{
    vpc_id = aws_default_vpc.default.id

    tags = {
        Name = "Test created by terraform"
    }
}*/

#resource "aws_subnet" "prod_mdle_sb" {}

#resource "aws_route_table" " prod_mdle_rt" {}

resource "aws_security_group" "prod_mdle_sg" {
    name        = "prod_web"
    description = "Allow http and https ports"

    ingress {
        from_port   = 80
        to_port     = 80
        protocol     = "tcp"
        cidr_blocks = ["0.0.0.0/0"] #ips range that it will be permited
    }
    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"] #ips range that it will be permited
    }
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"] 
    }
    egress {
        from_port   = 0 # no restrictions
        to_port     = 0 
        protocol     = "-1" # enabled all protocols 
        cidr_blocks = ["0.0.0.0/0"] #ips range that it will be permited
    }

    tags = {
        "terraform" : "true"
    }
}

resource "aws_network_acl" "prod_mdle_nacl" {
    vpc_id = aws_default_vpc.default.id

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

resource "aws_instance" "prod_mdle_ec2" {
    count   = 2

    ami             = "ami-062ca315b459c9e61" # "ami-02f3e801651bd39bc"
    instance_type   = "t2.micro"

    vpc_security_group_ids = [
        aws_security_group.prod_mdle_sg.id
    ]

    tags = {
        "Terraform" : "true"
    }
} 

resource "aws_eip_association" "prod_mdle_eipa" {
    instance_id     = aws_instance.prod_mdle_ec2.0.id
    allocation_id   = aws_eip.prod_mdle_eip.id
}

resource "aws_eip" "prod_mdle_eip" {

    tags = {
        "Terraform" : "true"
    }
}

resource "aws_elb" "prod_mdle_elb" {
    name            = "prod-mdle"
    instances       = aws_instance.prod_mdle_ec2.*.id
    subnets         = [ aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id ]
    security_groups = [ aws_security_group.prod_mdle_sg.id ]
    
    listener {
        instance_port       = 80
        instance_protocol   = "http"
        lb_port             = 80
        lb_protocol         = "http"
    }

    tags = {
        "Terraform" : "true"
    }
}