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
