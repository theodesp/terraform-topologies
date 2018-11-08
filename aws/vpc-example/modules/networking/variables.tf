// Variables

variable "vpc_cidr" {
  description = "The CIDR block of the VPC"
}

variable "public_subnet_cidr" {
  description = "The CIDR block of the public subnet"
}

variable "private_subnet_cidr" {
  description = "The CIDR block of the private subnet"
}

variable "environment" {
  description = "The environment"
}

variable "region" {
  description = "The region to launch the bastion host"
}

variable "availability_zone" {
  description = "The az that the resources will be launched"
}

variable "bastion_ami" {
  default = {
    "us-east-1" = "ami-059eeca93cf09eebd"
    "us-east-2" = "ami-059eeca93cf09eebd"
    "us-west-1" = "ami-059eeca93cf09eebd"
  }
}

variable "key_name" {
  description = "The public key for the bastion host"
}