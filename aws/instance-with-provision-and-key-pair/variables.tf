variable "region" {
  description = "The region to launch the bastion host"
  default = "us-east-1"
}

variable "environment" {
  description = "The environment"
  default = "staging"
}

variable "instance_ami" {
  default = "ami-059eeca93cf09eebd"
}

variable "public_key_path" {
  default = "staging_key.pub"
}

variable "private_key_path" {
  default = "staging_key"
}
