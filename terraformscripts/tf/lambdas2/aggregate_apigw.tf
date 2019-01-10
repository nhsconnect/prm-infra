module "apigw_endpoint" {
  source                    = "../modules/apigw_endpoint/"
  environment               = "${var.environment}"
  api_gateway_endpoint_name = "${var.api_gateway_endpoint_name}"
  aws_region                = "${var.aws_region}"
}

module "apigw_resource_retrieve" {
  source = "../modules/apigw_resource_request_parameter/"

  environment = "${var.environment}"

  apigw_endpoint_name             = "${module.apigw_endpoint.apigw_endpoint_name}"
  apigw_endpoint_public           = "${module.apigw_endpoint.apigw_endpoint_public}"
  apigw_endpoint_root_resource_id = "${module.apigw_endpoint.apigw_endpoint_root_resource_id}"
  apigw_endpoint_id               = "${module.apigw_endpoint.apigw_endpoint_id}"

  apigw_integration_lambda_function_arn = "${module.apigw_lambda_ehr_extract_handler.lambda_function_arn}"
  apigw_lambda_permission_function_name = "${module.apigw_lambda_ehr_extract_handler.lambda_function_name}"

  apigw_parent_path_part         = "retrieve"
  apigw_method_http_method       = "POST"
  apigw_method_request_parameter = "method.request.path.uuid"
}

module "apigw_resource_status" {
  source = "../modules/apigw_resource_request_parameter/"

  environment = "${var.environment}"

  apigw_endpoint_name             = "${module.apigw_endpoint.apigw_endpoint_name}"
  apigw_endpoint_public           = "${module.apigw_endpoint.apigw_endpoint_public}"
  apigw_endpoint_root_resource_id = "${module.apigw_endpoint.apigw_endpoint_root_resource_id}"
  apigw_endpoint_id               = "${module.apigw_endpoint.apigw_endpoint_id}"

  apigw_integration_lambda_function_arn = "${module.apigw_lambda_retrieve_status.lambda_function_arn}"
  apigw_lambda_permission_function_name = "${module.apigw_lambda_retrieve_status.lambda_function_name}"

  apigw_parent_path_part         = "status"
  apigw_method_http_method       = "POST"
  apigw_method_request_parameter = "method.request.path.uuid"
}
