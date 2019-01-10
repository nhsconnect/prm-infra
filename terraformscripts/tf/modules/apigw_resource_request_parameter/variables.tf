variable "apigw_endpoint_id" {}

variable "apigw_endpoint_root_resource_id" {}

variable "apigw_endpoint_name" {}

variable "apigw_endpoint_public" {}

variable "apigw_integration_lambda_function_arn" {}

variable "apigw_lambda_permission_function_name" {}

variable "environment" {
  default = "dev"
}

variable "apigw_path_part" {
  default = "{uuid}"
}

variable "apigw_parent_path_part" {
  default = "default_path"
}

variable "apigw_method_http_method" {
  default = "GET"
}

variable "apigw_method_authorisation" {
  default = "NONE"
}

variable "aws_region" {
  default = "eu-west-2"
}

variable "apigw_method_request_parameter" {
  default = "method.request.path.param"
}
