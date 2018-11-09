resource "null_resource" "local_exec" {
  provisioner "local-exec" {
    command = "echo ${var.memory} >> ${path.module}/memory.txt"
  }
}
