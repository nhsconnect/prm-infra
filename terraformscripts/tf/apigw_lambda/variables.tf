variable "aws_region" {
  default = "eu-west-2"
}

variable "environment" {
  default = "dev"
}

variable "api_gateway_endpoint_name" {
  default = "EhrExtractHandlerApi"
}

variable "vpc_id" {
}

variable "vpc_cidr" {
}

variable "vpc_subnet_private_ids" {}
