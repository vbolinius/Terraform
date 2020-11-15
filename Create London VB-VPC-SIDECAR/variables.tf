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
    vpc1_london_sidecar = "VB-VPC-SIDECAR"
  }
}


/*==================================================
Subnet names and CIDRs
===================================================*/

variable "my_london_subnets" {
  default = {
    vpc1_london         = "172.30.0.0/16"
    vpc1_london_subnet_1 = "172.30.10.0/24"
    vpc1_london_subnet_2 = "172.30.20.0/24"
    vpc1_london_subnet_3 = "172.30.30.0/24"
  }
}

variable "my_london_subnet_names" {
  default = {
    vpc1_london_subnet_1 = "VB-VPC-SIDECAR-SUBNET-1"
    vpc1_london_subnet_2 = "VB-VPC-SIDECAR-SUBNET-2"
    vpc1_london_subnet_3 = "VB-VPC-SIDECAR-SUBNET-3"
  }
}


/*==================================================
Route tables
===================================================*/

variable "my_london_route_table_names" {
  default = {
    vpc1_london_default = "VB-VPC-SIDECAR-RT-DEFAULT"
  }
}


/*==================================================
Internet Gateways
===================================================*/

variable "my_london_igw_names" {
  default = {
    vpc1_london_igw = "VB-VPC-SIDECAR-IGW"
  }
}


/*==================================================
Security Groups
===================================================*/

variable "my_london_security_group_names" {
  default = {
    vpc1_london_remote_access = "VB-VPC-SIDECAR-SG-REMOTE-ACCESS"
  }
}