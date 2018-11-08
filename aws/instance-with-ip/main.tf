provider "aws" {
  region = "${var.region}"
}

resource "aws_instance" "example" {
  ami           = "${var.instance_ami}"
  instance_type = "t2.micro"
}

/* Elastic IP for NAT */
resource "aws_eip" "eip" {
  instance = "${aws_instance.example.id}"
}

