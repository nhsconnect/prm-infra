variable "apigw_endpoint_id" {}

variable "apigw_endpoint_root_resource_id" {}

variable "apigw_endpoint_name" {}

variable "apigw_endpoint_public" {}

variable "apigw_path_part" {
  default = "default_path"
}

variable "apigw_method_http_method" {
  default = "GET"
}

variable "apigw_method_authorisation" {
  default = "NONE"
}
