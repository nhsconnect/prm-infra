module "apigw_endpoint" {
  source     = "../modules/apigw_endpoint/"
  environment = "${var.environment}"
  api_gateway_endpoint_name = "${var.api_gateway_endpoint_name}"
  aws_region = "${var.aws_region}"
}

module "apigw_resource" {
  source     = "../modules/apigw_resource/"

  apigw_endpoint_name = "${module.apigw_endpoint.apigw_endpoint_name}"
  apigw_endpoint_public = "${module.apigw_endpoint.apigw_endpoint_public}"
  apigw_endpoint_root_resource_id = "${module.apigw_endpoint.apigw_endpoint_root_resource_id}"
  apigw_endpoint_id = "${module.apigw_endpoint.apigw_endpoint_id}"

  apigw_path_part = "send"

  apigw_method_http_method = "POST"

  environment = "${var.environment}"

  apigw_integration_lambda_function_arn = "${module.apigw_lambda_ehr_extract_handler.lambda_function_arn}"

}
