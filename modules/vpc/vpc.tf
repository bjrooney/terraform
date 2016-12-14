variable "environment" {
}

variable "service" {
}

variable "cidr" {
}

variable "az1_cidr_public" {
}

variable "az2_cidr_public" {
}

variable "az3_cidr_public" {
}

variable "az1_cidr_private" {
}

variable "az2_cidr_private" {
}

variable "az3_cidr_private" {
}

variable "az1_rds" {
}

variable "az2_rds" {
}

variable "az3_rds" {
}

variable "az1_elasticache" {
}

variable "az2_elasticache" {
}

variable "az3_elasticache" {
}

variable "az1_nat_eip_id" {
}

variable "az2_nat_eip_id" {
}

variable "az3_nat_eip_id" {
}

variable "whitelist" {
}

variable "az1" {
  description = "Availability Zone for AZ1"
  default = "eu-west-1a"
}

variable "az2" {
  description = "Availability Zone for AZ2"
  default = "eu-west-1b"
}

variable "az3" {
  description = "Availability Zone for  AZ3"
  default = "eu-west-1c"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "vpc" {
  cidr_block = "${var.cidr}"
  enable_dns_hostnames = true
  tags {
    Name  = "vpc-${var.environment}"
  }
}

# Create a public subnet in az1 to launch our instances into
resource "aws_subnet" "az1_public" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.az1_cidr_public}"
  availability_zone       = "${var.az1}"
  map_public_ip_on_launch = true
  tags {
    Name = "${var.environment}-${var.service}-az1 {Public}"
  }
}

# Create a public subnet in az2 to launch our instances into
resource "aws_subnet" "az2_public" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.az2_cidr_public}"
  availability_zone       = "${var.az2}"
  map_public_ip_on_launch = true
  tags {
    Name = "${var.environment}-${var.service}-az2 {Public}"
  }
}

# Create a  public subnet in az3 to launch our instances into
resource "aws_subnet" "az3_public" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.az3_cidr_public}"
  availability_zone       = "${var.az3}"
  map_public_ip_on_launch = true
  tags {
    Name = "${var.environment}-${var.service}-az3 {Public}"
  }
}


# Create a subnet in az1 to launch our instances into
resource "aws_subnet" "az1_private" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.az1_cidr_private}"
  availability_zone       = "${var.az1}"
  map_public_ip_on_launch = false
  tags {
    Name = "${var.environment}-${var.service}-az1 {Private}"
  }
}

# Create a subnet in az2 to launch our instances into
resource "aws_subnet" "az2_private" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.az2_cidr_private}"
  availability_zone       = "${var.az2}"
  map_public_ip_on_launch = false
  tags {
    Name = "${var.environment}-${var.service}-az2 {Private}"
  }
}

# Create a subnet in az3 to launch our instances into
resource "aws_subnet" "az3_private" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.az3_cidr_private}"
  availability_zone       = "${var.az3}"
  map_public_ip_on_launch = false
  tags {
    Name = "${var.environment}-${var.service}-az3 {Private}"
  }
}

# VPC ASG
resource "aws_security_group" "lambda_sg" {
  name = "${var.environment}-lambda-sg"
  vpc_id  = "${aws_vpc.vpc.id}"
  description = "Lambda SG"

  tags {
    Name = "${var.environment}-lambda-sg"
  }

  # access VPC
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["${var.az1_cidr_private}","${var.az2_cidr_private}","${var.az3_cidr_private}"]
  }

  # Outbound 
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["${var.az1_cidr_private}","${var.az2_cidr_private}","${var.az3_cidr_private}"]
  }

}

# Create a subnet in az1 to launch our instances into
resource "aws_subnet" "az1_rds" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.az1_rds}"
  availability_zone       = "${var.az1}"
  map_public_ip_on_launch = false
  tags {
    Name = "${var.environment}-${var.service}-az1 {RDS}"
  }
}

# Create a subnet in az2 to launch our instances into
resource "aws_subnet" "az2_rds" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.az2_rds}"
  availability_zone       = "${var.az2}"
  map_public_ip_on_launch = false
  tags {
    Name = "${var.environment}-${var.service}-az2 {RDS}"
  }
}

# Create a subnet in az3 to launch our instances into
resource "aws_subnet" "az3_rds" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.az3_rds}"
  availability_zone       = "${var.az3}"
  map_public_ip_on_launch = false
  tags {
    Name = "${var.environment}-${var.service}-az3 {RDS}"
  }
}

# Create a subnet in az1 to launch our instances into
resource "aws_subnet" "az1_elasticache" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.az1_elasticache}"
  availability_zone       = "${var.az1}"
  map_public_ip_on_launch = false
  tags {
    Name = "${var.environment}-${var.service}-az1 {elasticache}"
  }
}

# Create a subnet in az2 to launch our instances into
resource "aws_subnet" "az2_elasticache" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.az2_elasticache}"
  availability_zone       = "${var.az2}"
  map_public_ip_on_launch = false
  tags {
    Name = "${var.environment}-${var.service}-az2 {elasticache}"
  }
}

# Create a subnet in az3 to launch our instances into
resource "aws_subnet" "az3_elasticache" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.az3_elasticache}"
  availability_zone       = "${var.az3}"
  map_public_ip_on_launch = false
  tags {
    Name = "${var.environment}-${var.service}-az3 {elasticache}"
  }
}

resource "aws_security_group" "elasticache" {

  name = "${var.environment}-${var.service}-elasticache-sg"
  vpc_id = "${aws_vpc.vpc.id}"
  description = "Elasticache SG"

  tags {
    Name = "${var.environment}-${var.service}-elasticache-sg"
  }

    # SSH
  ingress {
    from_port = 6379
    to_port = 6379
    protocol = "tcp"
    cidr_blocks = ["${var.cidr}"]
  }


  # outbound 
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elasticache_subnet_group" "elasticache" {
    name = "${var.environment}-${var.service}-elasticache-gw"
    description = "elasticache subnet group"
    subnet_ids = ["${aws_subnet.az1_elasticache.id}","${aws_subnet.az2_elasticache.id}","${aws_subnet.az3_elasticache.id}"]
}


# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "gateway" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
        Name = "${var.environment}-${var.service}-gateway {Public}"
  }
}



# Public Route Table
resource "aws_route_table" "public" {
    vpc_id = "${aws_vpc.vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.gateway.id}"
    }

    tags {
        Name = "${var.environment}-${var.service}-route {Public}"
    }
}



# Provides a resource for managing the main routing table of a VPC.
resource "aws_main_route_table_association" "route_table_association" {
    vpc_id = "${aws_vpc.vpc.id}"
    route_table_id = "${aws_route_table.public.id}"


}

# Add az1 to public route table
resource "aws_route_table_association" "az1_public" {
    subnet_id = "${aws_subnet.az1_public.id}"
    route_table_id = "${aws_route_table.public.id}"
}

# Add az2 to public route table
resource "aws_route_table_association" "az2_public" {
    subnet_id = "${aws_subnet.az2_public.id}"
    route_table_id = "${aws_route_table.public.id}"
}

# Add az3 to public route table
resource "aws_route_table_association" "az3_public" {
    subnet_id = "${aws_subnet.az3_public.id}"
    route_table_id = "${aws_route_table.public.id}"
}

resource "aws_nat_gateway" "nat_gateway_az1" {
  //other arguments
  allocation_id = "${var.az1_nat_eip_id}"
  subnet_id ="${aws_subnet.az1_public.id}"
  depends_on = ["aws_internet_gateway.gateway"]
}

resource "aws_nat_gateway" "nat_gateway_az2" {
  //other arguments
  allocation_id = "${var.az2_nat_eip_id}"
  subnet_id ="${aws_subnet.az2_public.id}"
  depends_on = ["aws_internet_gateway.gateway"]
}

resource "aws_nat_gateway" "nat_gateway_az3" {
  //other arguments
  allocation_id = "${var.az3_nat_eip_id}"
  subnet_id ="${aws_subnet.az3_public.id}"
  depends_on = ["aws_internet_gateway.gateway"]
}



# Public Route Table
resource "aws_route_table" "nat_az1" {
    vpc_id = "${aws_vpc.vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_nat_gateway.nat_gateway_az1.id}"
    }

    tags {
        Name = "${var.environment}-${var.service}-routing_table {nat_az1}"
    }
}

resource "aws_route_table" "nat_az2" {
    vpc_id = "${aws_vpc.vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_nat_gateway.nat_gateway_az2.id}"
    }

    tags {
        Name = "${var.environment}-${var.service}-routing_table {nat_az2}"
    }
}

resource "aws_route_table" "nat_az3" {
    vpc_id = "${aws_vpc.vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_nat_gateway.nat_gateway_az3.id}"
    }

    tags {
        Name = "${var.environment}-${var.service}-routing_table {nat_az3}"
    }
}

resource "aws_security_group" "peering" {
  name = "${var.environment}-peering-sg"
  vpc_id = "${aws_vpc.vpc.id}"
  description = "SSH peering"

  tags {
    name = "${var.environment}-peering-sg"
  }

  # access from subnets
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${split(",", var.whitelist)}"]
  }

    # HTTPS
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["${split(",", var.whitelist)}"]
  }

  # VPN
  ingress {
    from_port = 9392
    to_port   = 9392
    protocol  = "tcp"
    cidr_blocks = ["${split(",", var.whitelist)}"]
  }

    # VPN
  ingress {
    from_port = 943
    to_port   = 943
    protocol = "tcp"
    cidr_blocks = ["${split(",", var.whitelist)}"]
  }

  # VPN
  ingress {
    from_port = 1194
    to_port = 1194
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound 
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


}

# Add az1 to private route table
resource "aws_route_table_association" "az1_private" {
    subnet_id = "${aws_subnet.az1_private.id}"
    route_table_id = "${aws_route_table.nat_az1.id}"
}

# Add az2 to private route table
resource "aws_route_table_association" "az2_private" {
    subnet_id = "${aws_subnet.az2_private.id}"
    route_table_id = "${aws_route_table.nat_az2.id}"
}

# Add az3 to private route table
resource "aws_route_table_association" "az3_private" {
    subnet_id = "${aws_subnet.az3_private.id}"
    route_table_id = "${aws_route_table.nat_az3.id}"
}



output "az1_cidr_public_id" {
  value = "${aws_subnet.az1_public.id}"
}

output "az2_cidr_public_id" {
  value = "${aws_subnet.az2_public.id}"
}

output "az3_cidr_public_id" {
  value = "${aws_subnet.az3_public.id}"
}

output "az1_cidr_private_id" {
  value = "${aws_subnet.az1_private.id}"
}

output "az2_cidr_private_id" {
  value = "${aws_subnet.az2_private.id}"
}

output "az3_cidr_private_id" {
  value = "${aws_subnet.az3_private.id}"
}

output "az1_rds_id" {
  value = "${aws_subnet.az1_rds.id}"
}

output "az2_rds_id" {
  value = "${aws_subnet.az2_rds.id}"
}

output "az3_rds_id" {
  value = "${aws_subnet.az3_rds.id}"
}

output "az1_elasticache_id" {
  value = "${aws_subnet.az1_elasticache.id}"
}

output "az2_elasticache_id" {
  value = "${aws_subnet.az2_elasticache.id}"
}

output "az3_elasticache_id" {
  value = "${aws_subnet.az3_elasticache.id}"
}

output "aws_vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "aws_route_table_id" {
  value = "${aws_route_table.public.id}"
}

output "aws_sg_elasticache_id" {
  value = "${aws_security_group.elasticache.id}"
}

output "aws_elasticache_subnet_group_name" {
  value = "${aws_elasticache_subnet_group.elasticache.name}"
}

output "aws_security_group_peering_id" {
  value = "${aws_security_group.peering.id}"
}