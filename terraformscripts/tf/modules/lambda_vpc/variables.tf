variable "aws_region" {
  default = "eu-west-2"
}

variable "environment" {
  default = "dev"
}

variable "lambda_name" {
  default = "LambdaName"
}

variable "lambda_runtime" {
  default = "nodejs8.10"
}

variable "lambda_handler" {
  default = "main.handler"
}

variable "vpc_id" {
  default = "vpc-8f3aaae7"
}

variable "vpc_cidr" {
  default = "172.31.0.0/16"
}

variable "private_subnet_ids" {
   description = "A comma-separated list of subnet IDs associated with the Lambda function."
}

variable "lambda_environment_variables" {
  type = "map"
  default = {}
}