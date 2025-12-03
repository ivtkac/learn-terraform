resource "local_file" "hello-world" {
  filename = var.filename
  content  = "Hello from terraform with variables!"
}
