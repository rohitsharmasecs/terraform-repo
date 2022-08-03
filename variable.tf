variable "region" {
  description = "The region in which to deploy the VPC."
  default     = "us-west-1"
}

variable "vpc_name" {
  description = "The name of the VPC."
  default     = "vpc-tf"
}

variable "vpc_cidr_block" {
  description = "The CIDR block of the VPC."
  default     = "10.0.0.0/16"
}

variable "vpc_instance_tenancy" {
  default     = "default"
  description = "Tenancy of instances"
}

variable "public_subnet_name" {
  description = "The name of the Public subnet."
  default     = "public-subnet"
}

variable "public_subnet_cidr_block" {
  description = "The CIDR block of the public subnet."
  default     = "10.0.0.0/24"
}

variable "public_subnet_AZ" {
  description = "AZ of public subnet."
  default     = "us-west-1a"
}

variable "private_subnet_name" {
  description = "The name of the private subnet."
  default     = "private-subnet"
}

variable "private_subnet_cidr_block" {
  description = "The CIDR block of the private subnet."
  default     = "10.0.1.0/24"
}

variable "private_subnet_AZ" {
  description = "AZ of private subnet."
  default     = "us-west-1b"
}

variable "IG_name" {
  description = "The name of internet gateway."
  default     = "IG"
}

variable "eip_name" {
  description = "The name of elastic IP."
  default     = "my_eip"
}

variable "NAT_GATEWAY" {
  description = "The name of nat gateway."
  default     = "nat-GW"
}

variable "SG" {
  description = "The name of security group."
  default     = "Security-group"
}

variable "ami_id" {
  description = "The ID of ami."
  default     = "ami-085284d24fe829cd0"
}

variable "public_instance_typee" {
  description = "public instance type"
  default     = "t2.micro"
}

variable "key_pair_namee" {
  description = "key pair name"
  default     = "terra-key-pair"
}

variable "public_instance_name" {
  description = "instance name"
  default     = "public-EC2"
}

variable "private_ami_id" {
  description = "The ID of ami."
  default     = "ami-085284d24fe829cd0"
}

variable "private_instance_typee" {
  description = "private instance type"
  default     = "t2.micro"
}

variable "private_key_pair_namee" {
  description = "key pair name"
  default     = "terra-key-pair"
}

variable "private_instance_name" {
  description = "instance name"
  default     = "private-EC2"
}
