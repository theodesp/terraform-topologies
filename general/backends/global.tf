terraform {
  backend "http" {
    address = "http://localhost:8090"
    lock_address = "http://localhost:8090"
    unlock_address = "http://localhost:8090"
  }
}
