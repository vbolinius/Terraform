/*===============================================================================
Author: Vern Bolinius
Date: 2020 11 13
Revision: 1.0
Description:
This code sets up elements of a testing environment
in the AWS London region that I find useful.  Using
the same code with different sets of input variables
(CIDR ranges, device names, etc.), the user can
deploy separate, multiple VPC instances.  This code creates:
VPCs:
 - A VPC in the AWS London region
Gateways:
 - An Internet Gateway
 - A NAT Gateway
Subnets:
 - A private subnet in the VPC
 - A public subnet in the VPC
Route Tables and Route Table Associations:
 - A route table for the private VPC, associated with the private subnet
 - A route table for the public VPC, associated with the public subnet
 - A default route table for the VPC
Routes:
 - A default route for the private subnet, pointing to the NAT GW
 - A default route for the public subnet, pointing to the Internet GW
 - A default route for the VPC, pointing to the Internet GW
Security Groups:
 - A security group allowing RDP, SSH and ICMP
EC2 Instances:
 - An AWS Linux t2.micro instance in the public subnet with a designated IP
 - An AWS Linux t2.micro instance in the private subnet with a designated IP

================================================================================*/


/*==================================================
AWS Providers and Regions
===================================================*/

provider "aws" {
  access_key 	= var.access_key
  secret_key	= var.secret_key
  alias 		= "london"
  region     	= var.region["london"]
}


/*==================================================
Create the VPC in London
===================================================*/

/* Create the VPC */
resource "aws_vpc" "vpc1_london" {
  provider             = aws.london
  cidr_block           = var.my_london_subnets["vpc1_london"]
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = var.my_london_vpc_names["vpc1_name"]
  }
}


/* Default route table for the VPC */
resource "aws_default_route_table" "vpc1_london_routetable" {
  provider               = aws.london
  default_route_table_id = aws_vpc.vpc1_london.default_route_table_id
  tags = {
    Name = var.my_london_routetable_names["vpc1_london_default"]
  }
}

/* Assign the default route to the IGW */
resource "aws_route" "vpc1_london_IGW_route" {
  provider               = aws.london
  route_table_id         = aws_vpc.vpc1_london.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.vpc1_london_IGW.id
}


/*==================================================
Create the PRIVATE subnet, with its own route table
and default route through the NAT gateway
===================================================*/

/* Create the subnet */
resource "aws_subnet" "vpc1_london_private" {
  provider                = aws.london
  vpc_id                  = aws_vpc.vpc1_london.id
  cidr_block              = var.my_london_subnets["vpc1_london_private"]
  availability_zone       = var.availability_zones["az1"]
  map_public_ip_on_launch = false
  tags = {
    Name = var.my_london_subnet_names["vpc1_london_private"]
  }
}

/* Create the route table */
resource "aws_route_table" "vpc1_london_private_route_table" {
  provider      = aws.london
  vpc_id        = aws_vpc.vpc1_london.id
  tags = {
    Name = var.my_london_routetable_names["vpc1_london_private"]
  }
}

/* Associate the subnet with the subnet route table */
resource "aws_route_table_association" "vpc1_london_private_route_table_association" {
  provider       = aws.london
  subnet_id      = aws_subnet.vpc1_london_private.id
  route_table_id = aws_route_table.vpc1_london_private_route_table.id
}

/* Set the default route to the NAT gateway */
resource "aws_route" "vpc1_london_private_NATGW_route" {
  provider               = aws.london
  route_table_id         = aws_route_table.vpc1_london_private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.vpc1_london_public_subnet_NATGW.id
}


/*==================================================
Create the PUBLIC subnet, with its own route table
and default route through the Internet gateway
===================================================*/

/* Create the subnet */
resource "aws_subnet" "vpc1_london_public" {
  provider                = aws.london
  vpc_id                  = aws_vpc.vpc1_london.id
  cidr_block              = var.my_london_subnets["vpc1_london_public"]
  availability_zone       = var.availability_zones["az1"]
  map_public_ip_on_launch = true
  tags = {
    Name = var.my_london_subnet_names["vpc1_london_public"]
  }
}

/* Create the route table */
resource "aws_route_table" "vpc1_london_public_route_table" {
  provider      = aws.london
  vpc_id        = aws_vpc.vpc1_london.id
  tags = {
    Name = var.my_london_routetable_names["vpc1_london_public"]
  }
}

/* Associate the subnet with the subnet route table */
resource "aws_route_table_association" "vpc1_london_public_route_table_association" {
  provider       = aws.london
  subnet_id      = aws_subnet.vpc1_london_public.id
  route_table_id = aws_route_table.vpc1_london_public_route_table.id
}

/* Set the default route to the Internet gateway */
resource "aws_route" "vpc1_london_public_IGW_route" {
  provider               = aws.london
  route_table_id         = aws_route_table.vpc1_london_public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.vpc1_london_IGW.id
}


/*==================================================
Create the Internet gateway
===================================================*/

resource "aws_internet_gateway" "vpc1_london_IGW" {
  provider = aws.london
  vpc_id   = aws_vpc.vpc1_london.id
  tags = {
    Name = var.my_london_igw_names["vpc1_london_igw"]
  }
}


/*==================================================
Create the NAT gateway for PUBLIC subnet
===================================================*/

/* Elastic IP for the NAT */
resource "aws_eip" "vpc1_london_public_NATGW_IP" {
  provider = aws.london
  vpc = true
  tags = {
    Name = var.my_london_eip_names["vpc1_london_public_NATGW_IP"]
  }
}

/* NAT Gateway */
resource "aws_nat_gateway" "vpc1_london_public_subnet_NATGW" {
  provider = aws.london
  allocation_id = aws_eip.vpc1_london_public_NATGW_IP.id
  subnet_id = aws_subnet.vpc1_london_public.id
  tags = {
    Name = var.my_london_nat_gw_names["vpc1_london_public_nat_gw"]
  }
}


/*=============================
Create EC2 Linux instances
==============================*/

/* Find the most recent Linux image owned by AWS */
data "aws_ami" "linux" {
  provider = aws.london
  most_recent = true
  filter {
    name = "name"
    values = ["amzn-ami-hvm-????.??.?.????????-x86_64-gp2"]
  }
  owners = ["amazon"]
}

/* Create an EC2 instance in the PUBLIC subnet */
resource "aws_instance" "vpc1_london_ec2_linux_public" {
  provider = aws.london
  ami   = data.aws_ami.linux.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.vpc1_london_public.id
  private_ip = var.my_london_vm_IP_addresses["vpc1_london_public_linux_1"]
  key_name = var.aws_key_pairs["london"]
  vpc_security_group_ids = [aws_security_group.vpc1_london_remote_access.id] 
  tags = {
    Name = var.my_london_vm_names["vpc1_london_public_linux_1"]
  }
}


/* Create an EC2 instance in the PRIVATE subnet */
resource "aws_instance" "vpc1_london_ec2_linux_private" {
  provider = aws.london
  ami   = data.aws_ami.linux.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.vpc1_london_private.id
  private_ip = var.my_london_vm_IP_addresses["vpc1_london_private_linux_1"]
  key_name = var.aws_key_pairs["london"]
  vpc_security_group_ids = [aws_security_group.vpc1_london_remote_access.id] 
  tags = {
    Name = var.my_london_vm_names["vpc1_london_private_linux_1"]
  }
}


/*=============================
Create EC2 Security Groups
==============================*/

/* Allow Ping, RDP and SSH only */
resource "aws_security_group" "vpc1_london_remote_access" {
  provider = aws.london
  
  name          = var.my_london_security_group_names["vpc1_london_remote_access"]
  description   = "Allow ping, rdp and ssh"
  vpc_id        = aws_vpc.vpc1_london.id

  ingress {
    description = "Allow RDP"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow all ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.my_london_security_group_names["vpc1_london_remote_access"]
  }
}
