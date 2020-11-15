/*===============================================================================
Author: Vern Bolinius
Date: 2020 11 15
Revision: 1.0
Description:
This code sets up a VPC to be used as the "sidecar VPC" to a
VMware Cloud on AWS SDDC.  It creates:
VPCs:
 - A single VPC in the AWS London region
Gateways:
 - An Internet Gateway
Subnets:
 - Three subnets, one within each London AZ
Route Tables and Route Table Associations:
 - A default route table for the VPC
 - Each subnet is associated with the default route table for the VPC
Routes:
 - A default route for the VPC, pointing to the Internet GW
Security Groups:
 - A security group allowing RDP, SSH and ICMP
================================================================================*/

/*==================================================
AWS Providers and Regions
===================================================*/

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region["london"]
  alias = "london"
}


/*==================================================
Create VB-VPC-SIDECAR
===================================================*/

resource "aws_vpc" "vpc1_london" {
  provider 		  		= aws.london
  cidr_block           	= var.my_london_subnets["vpc1_london"]
  enable_dns_hostnames 	= true
  enable_dns_support   	= true
  tags = {
    Name = var.my_london_vpc_names["vpc1_london_sidecar"]
  }
}


/*==================================================
Create Subnets and route table associations.  Each
Subnet is in its own Availability Zone and is
associated with the Default route table.
===================================================*/

/* Subnet 1 */
resource "aws_subnet" "vpc1_london_subnet_1" {
  provider                = aws.london
  vpc_id                  = aws_vpc.vpc1_london.id
  cidr_block              = var.my_london_subnets["vpc1_london_subnet_1"]
  availability_zone       = var.availability_zones["az1"]
  map_public_ip_on_launch = true
  tags = {
    Name = var.my_london_subnet_names["vpc1_london_subnet_1"]
  }
}

resource "aws_route_table_association" "vpc1_london_subnet_1_routetable" {
  provider       = aws.london
  subnet_id      = aws_subnet.vpc1_london_subnet_1.id
  route_table_id = aws_vpc.vpc1_london.default_route_table_id
}

/* Subnet 2 */
resource "aws_subnet" "vpc1_london_subnet_2" {
  provider                = aws.london
  vpc_id                  = aws_vpc.vpc1_london.id
  cidr_block              = var.my_london_subnets["vpc1_london_subnet_2"]
  availability_zone       = var.availability_zones["az2"]
  map_public_ip_on_launch = true
  tags = {
    Name = var.my_london_subnet_names["vpc1_london_subnet_2"]
  }
}

resource "aws_route_table_association" "vpc1_london_subnet_2_routetable" {
  provider       = aws.london
  subnet_id      = aws_subnet.vpc1_london_subnet_2.id
  route_table_id = aws_vpc.vpc1_london.default_route_table_id
}

/* Subnet 3 */
resource "aws_subnet" "vpc1_london_subnet_3" {
  provider                = aws.london
  vpc_id                  = aws_vpc.vpc1_london.id
  cidr_block              = var.my_london_subnets["vpc1_london_subnet_3"]
  availability_zone       = var.availability_zones["az3"]
  map_public_ip_on_launch = true
  tags = {
    Name = var.my_london_subnet_names["vpc1_london_subnet_3"]
  }
}

resource "aws_route_table_association" "vpc1_london_subnet_3_routetable" {
  provider       = aws.london
  subnet_id      = aws_subnet.vpc1_london_subnet_3.id
  route_table_id = aws_vpc.vpc1_london.default_route_table_id
}


/*==================================================
Create VPC Default Route Table
===================================================*/

resource "aws_default_route_table" "vpc1_london_routetable" {
  provider               = aws.london
  default_route_table_id = aws_vpc.vpc1_london.default_route_table_id
  tags = {
    Name = var.my_london_route_table_names["vpc1_london_default"]
  }
}


/*==================================================
Create VPC Internet Gateway
===================================================*/

/* Create the gateway */
resource "aws_internet_gateway" "vpc1_london_IGW" {
  provider = aws.london
  vpc_id   = aws_vpc.vpc1_london.id
  tags = {
    Name = var.my_london_igw_names["vpc1_london_igw"]
  }
}


/* Assign the VPC default route to the IGW */
resource "aws_route" "vpc1_london_IGW_route" {
  provider               = aws.london
  route_table_id         = aws_vpc.vpc1_london.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.vpc1_london_IGW.id
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