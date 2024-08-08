source "amazon-ebs" "ubuntu" {
  region          = "eu-west-1"
  source_ami      = "ami-0905a3c97561e0b69"
  instance_type   = "t2.micro"
  ssh_username    = "ubuntu"
  ami_name        = "custom-ubuntu-ami-${timestamp()}"
  ami_description = "Ubuntu with MongoDB Shell and MySQL preinstalled"
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "ansible" {
    playbook_file = "./ansible/playbook.yml"
  }
}
