variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "terrakey"
}

variable "ami_id" {
  description = "AMI ID for the instances"
  type        = string
}

variable "aws_region" {
  default = "eu-west-1"
}
