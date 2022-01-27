

resource "null_resource" "existing_resource" {
  provisioner "local-exec" {
    command = "terraform state pull | Select-String -Pattern {$var.ResName} > {$var.ResName}"
    interpreter = ["PowerShell", "-Command"]
  }
}
