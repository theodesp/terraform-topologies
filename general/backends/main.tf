resource "null_resource" "local_exec" {
  provisioner "local-exec" {
    command = "echo ${data.terraform_remote_state.memory.id} >> ${path.module}/memory.txt"
  }
  provisioner "local-exec" {
    command = "echo ${var.memory} >> ${path.module}/memory.txt"
  }
}

data "terraform_remote_state" "memory" {
  backend = "http"

  config {
    address = "http://localhost:8090"
    lock_address = "http://localhost:8090"
    unlock_address = "http://localhost:8090"
    name = "memory-prod"
  }
}
