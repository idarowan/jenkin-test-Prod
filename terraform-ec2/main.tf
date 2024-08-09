resource "aws_instance" "example" {
  count         = 5
  ami           = var.ami_id
  instance_type = "t2.micro"
  key_name      = var.key_name

  tags = {
    Name = "ExampleInstance"
  }
}

output "instance_ids" {
  value = aws_instance.example.*.id
}

output "public_ips" {
  value = aws_instance.example.*.public_ip
}