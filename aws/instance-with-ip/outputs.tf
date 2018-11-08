output "ip" {
  sensitive = true
  value = "${aws_eip.eip.public_ip}"
}
