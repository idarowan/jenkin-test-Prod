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

variable "PATH_TO_PRIVATE_KEY" {
  default = "terrakey"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "terrakey.pub"
}