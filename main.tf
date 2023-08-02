provider "aws" {
  region = var.REGION
}

// create vpc
resource "aws_vpc" "openvpn_vpc" {
  cidr_block = var.OPENVPN_VPC_CIDR

  tags = {
    "Name" = "${var.PREFIX}_VPC"
  }
}

// create public subnets
resource "aws_subnet" "openvpn_public_subnet" {
  count                   = var.TOTAL_PUBLIC_SUBNETS
  vpc_id                  = aws_vpc.openvpn_vpc.id
  cidr_block              = element(var.OPENVPN_PUBLIC_SUBNET_CIDRS, count.index)
  availability_zone       = element(local.AVAILABILITY_ZONES, count.index)
  map_public_ip_on_launch = true

  tags = {
    "Name" = "${var.PREFIX}_PUBLIC_SUBNET_${count.index}"
  }

}

// create private subnets
resource "aws_subnet" "openvpn_private_subnet" {
  count                   = var.TOTAL_PRIVATE_SUBNETS
  vpc_id                  = aws_vpc.openvpn_vpc.id
  cidr_block              = element(var.OPENVPN_PRIVATE_SUBNET_CIDRS, count.index)
  availability_zone       = element(local.AVAILABILITY_ZONES, count.index)
  map_public_ip_on_launch = false

  tags = {
    "Name" = "${var.PREFIX}_PRIVATE_SUBNET_${count.index}"
  }

}

// elastic ip
resource "aws_eip" "nat_eip" {
  vpc = true
}

// create nat gateway
resource "aws_nat_gateway" "openvpn_ng" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.openvpn_public_subnet[0].id
}




// create internet gateway for vpc
resource "aws_internet_gateway" "openvpn_ig" {
  vpc_id = aws_vpc.openvpn_vpc.id

}

# resource "aws_internet_gateway_attachment" "openvpn_vpc_ig_attachment" {
#   vpc_id              = aws_vpc.openvpn_vpc.id
#   internet_gateway_id = aws_internet_gateway.openvpn_ig.id

# }


# create a route table for the public subnet
resource "aws_route_table" "openvpn_public_route_table" {
  vpc_id = aws_vpc.openvpn_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.openvpn_ig.id
  }

  tags = {
    Name = "${var.PREFIX}_PUBLIC_ROUTE"
  }

}

# associate the public route table with the public subnet
resource "aws_route_table_association" "openvpn_public_route_table_association" {
  count          = var.TOTAL_PUBLIC_SUBNETS
  subnet_id      = element(aws_subnet.openvpn_public_subnet.*.id, count.index)
  route_table_id = aws_route_table.openvpn_public_route_table.id

}


# create a route table for the private subnet
resource "aws_route_table" "openvpn_private_route_table" {
  vpc_id = aws_vpc.openvpn_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.openvpn_ng.id
  }

  tags = {
    Name = "${var.PREFIX}_PRIVATE_ROUTE"
  }

}

# associate the private route table with the private subnet
resource "aws_route_table_association" "openvpn_private_route_table_association" {
  count          = var.TOTAL_PRIVATE_SUBNETS
  subnet_id      = element(aws_subnet.openvpn_private_subnet.*.id, count.index)
  route_table_id = aws_route_table.openvpn_private_route_table.id

}

// create security group for ec2 instance
resource "aws_security_group" "openvpn_sg" {
  name        = "${var.PREFIX}_server_sg"
  description = "allow permission for openvpn setup"
  vpc_id      = aws_vpc.openvpn_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]


  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]


  }

  ingress {
    from_port   = 943
    to_port     = 943
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "${var.PREFIX}_sg"
  }

}

// create ssh key for openvpn server 
resource "aws_key_pair" "openvpn_key" {
  key_name   = var.OPENVPN_KEY
  public_key = file(var.PUBLIC_KEY_PATH)
}

// create elastic ip for openvpn ec2

resource "aws_eip" "openvpn_server_eip" {
  vpc      = true
  instance = aws_instance.openvpn_server.id
}


resource "aws_instance" "openvpn_server" {
  ami                    = var.OPENVPN_AMI
  instance_type          = var.OPENVPN_INSTANCE_TYPE
  key_name               = aws_key_pair.openvpn_key.key_name
  subnet_id              = aws_subnet.openvpn_public_subnet[0].id
  vpc_security_group_ids = [aws_security_group.openvpn_sg.id]

  ebs_block_device {
    device_name = var.EBS_DEVICE_NAME
    volume_size = var.VOL_SIZE
  }

  tags = {
    "Name" = "${var.PREFIX}_SERVER"
  }


}



##  TEST SECTION  ##



# resource "aws_instance" "test_server" {
#   ami                    = "ami-05ec72576b2b4738f"
#   instance_type          = "t3.micro"
#   key_name               = aws_key_pair.openvpn_key.key_name
#   subnet_id              = aws_subnet.openvpn_private_subnet[0].id
#   vpc_security_group_ids = [aws_security_group.test_sg.id]


#   tags = {
#     "Name" = "${var.PREFIX}_TEST_SERVER"
#   }


# }

# resource "aws_security_group" "test_sg" {
#   name        = "test_sg"
#   description = "test_sg"
#   vpc_id      = aws_vpc.openvpn_vpc.id

#   ingress {
#     from_port       = 0
#     to_port         = 0
#     protocol        = "-1"
#     security_groups = [aws_security_group.openvpn_sg.id]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]

#   }

#   tags = {
#     Name = "${var.PREFIX}_test_sg"
#   }



# }
