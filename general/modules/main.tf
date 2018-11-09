module "child" {
  source = "./child"

  memory = "1G"
}

resource "null_resource" "local_exec" {
  provisioner "local-exec" {
    command = "echo ${module.child.received} >> ${path.module}/memory.txt"
  }
}
