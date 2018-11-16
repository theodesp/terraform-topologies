provider "aws" {
  region = "${var.region}"
}

resource "aws_key_pair" "mykey" {
  key_name = "staging_key"
  public_key = "${file("${var.public_key_path}")}"
}

resource "aws_instance" "example" {
  ami = "${var.instance_ami}"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.mykey.key_name}"

  provisioner "file" {
    source = "script.sh"
    destination = "/tmp/script.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "sudo /tmp/script.sh"
    ]
  }
  connection {
    user = "ubuntu"
    private_key = "${file("${var.private_key_path}")}"
  }
}

/* Elastic IP for NAT */
resource "aws_eip" "eip" {
  instance = "${aws_instance.example.id}"
}

