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