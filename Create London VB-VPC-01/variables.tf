/*===================================================================================
Author: Vern Bolinius
Date: 2020 11 13
Revision: 1.0
Description:
This is the variable definition file for code that sets up elements of a testing
environment in the AWS London region that I find useful.  Using the same code with
different sets of input variables (CIDR ranges, device names, etc.), the user can
deploy separate, multiple VPC instances.  This associated code creates:
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

NOTE: By convention, I preface the names of all AWS constructs with my initals - "VB"
====================================================================================*/



/*==================================================
AWS region and Key-pairs in that region, for Europe
===================================================*/

variable "access_key" {
	description = "AWS Access Key"
	type		= string
}

variable "secret_key" {
	description = "AWS Secret Key"
	type		= string
}

variable "region" {
  default = {
    ireland   = "eu-west-1"
    london    = "eu-west-2"
    paris     = "eu-west-3"
    frankfurt = "eu-central-1"
    stockholm = "eu-north-1"
  }
}

variable "aws_key_pairs" {
  default = {
    london    = "VB-SET-AWS-KeyPair-London"
    frankfurt = "VB-SET-AWS-KeyPair-Frankfurt"
    dublin    = "VB-SET-AWS-KeyPair-Dublin"
    paris     = "VB-SET-AWS-KeyPair-Paris"
    stockholm = "VB-SET-AWS-KeyPair-Stockholm"
  }
}

variable "availability_zones" {
  default = {
    az1   = "eu-west-2a"
    az2   = "eu-west-2b"
    az3   = "eu-west-2c"
  }
}

/*==================================================
VPC names
===================================================*/

variable "my_london_vpc_names" {
  default = {
    vpc1_name = "VB-VPC-01"
  }
}


/*==================================================
Subnet names and CIDRs
===================================================*/

variable "my_london_subnets" {
  default = {
    vpc1_london         = "172.20.0.0/16"
    vpc1_london_private = "172.20.100.0/24"
    vpc1_london_public = "172.20.200.0/24"
  }
}

variable "my_london_subnet_names" {
  default = {
    vpc1_london_private = "VB-VPC-01-SN-PRIVATE"
    vpc1_london_public = "VB-VPC-01-SN-PUBLIC"
  }
}


/*==================================================
Route tables
===================================================*/

variable "my_london_routetable_names" {
  default = {
    vpc1_london_private = "VB-VPC-01-RT-PRIVATE"
    vpc1_london_public = "VB-VPC-01-RT-PUBLIC"
    vpc1_london_default = "VB-VPC-01-RT-DEFAULT"
  }
}

variable "my_london_igw_names" {
  default = {
    vpc1_london_igw = "VB-VPC-01-IGW"
  }
}


/*==================================================
Internet Gateways
===================================================*/
variable "my_london_eip_names" {
  default = {
    vpc1_london_public_NATGW_IP = "VB-VPC-01-PUBLIC-SN-NAT-EIP"
  }
}

/*==================================================
NAT Gateways
===================================================*/
variable "my_london_nat_gw_names" {
  default = {
    vpc1_london_public_nat_gw = "VB-VPC-01-PUBLIC-SN-NATGW"
  }
}

/*==================================================
EC2 Instances
===================================================*/

variable "my_london_vm_names" {
  default = {
    vpc1_london_public_linux_1 = "VB-VPC-01-PUBLIC-LINUX-01"
    vpc1_london_private_linux_1 = "VB-VPC-01-PRIVATE-LINUX-01"
  }
}

variable "my_london_vm_IP_addresses" {
  default = {
    vpc1_london_public_linux_1 = "172.20.200.10"
    vpc1_london_private_linux_1 = "172.20.100.10"
  }
}


/*==================================================
Security Groups
===================================================*/

variable "my_london_security_group_names" {
  default = {
    vpc1_london_remote_access = "VB-VPC-01-SG-REMOTE-ACCESS"
  }
}