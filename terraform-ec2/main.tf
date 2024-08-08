resource "aws_instance" "example" {
  count         = 5
  ami           = var.ami_id
  instance_type = "t2.micro"
  key_name      = "terrakey"  // Replace with your key pair name

  tags = {
    Name = "ExampleInstance"
  }
}