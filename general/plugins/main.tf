resource "null_resource" "local_exec" {
  provisioner "local-exec" {
    command = "echo ${data.template_file.init.rendered} >> ${path.module}/memory.txt"
  }
}

# Template for initial configuration bash script
data "template_file" "init" {
  template = "$${consul_address}:1234"

  vars {
    consul_address = "192.168.0.1"
  }
}
