variable "AWS_ACCESS_KEY" {
}

variable "AWS_SECRET_KEY" {
}

variable "mongodb_atlas_api_pub_key" {
}

variable "mongodb_atlas_api_pri_key" {
}

variable "mongodb_atlas_api_work_pub_key" {
}
variable "mongodb_atlas_api_work_pri_key" {
}

variable "PATH_TO_PRIVATE_KEY" {
  default = "terrakey"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "terrakey.pub"
}

variable "project_id" {
  default = "658d4575d481b84d71cc2cb5"
}

variable "INSTANCE_USERNAME" {
  default = "ubuntu"
}

variable "ami_id" {
  description = "AMI ID for the instances"
  type        = string
}

variable "aws_region" {
  default = "eu-west-1"
}