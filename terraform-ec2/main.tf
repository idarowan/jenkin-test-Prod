resource "aws_instance" "example" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_traffic.id]
  subnet_id     = aws_subnet.publicsubnet.id
  key_name      = var.key_name

  tags = {
    Name = "Public-Jenkins-EC2"
  }
}

output "instance_ids" {
  value = aws_instance.example.id
}

output "public_ips" {
  value = aws_instance.example.public_ip
}