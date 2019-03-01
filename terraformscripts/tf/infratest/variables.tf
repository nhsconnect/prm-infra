variable "aws_region" {
  default = "eu-west-2"
}

variable "environment" {
  default = "eu-west-2"
}

variable "vpc_id" {}

variable "vpc_subnet_private_ids" {}

variable "vpc_egress_all_security_group" {}

variable "role_arn" {
}
