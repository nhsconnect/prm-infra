module "apigw_endpoint" {
  source     = "../modules/apigw_endpoint/"
  environment = "${var.environment}"
  api_gateway_endpoint_name = "${var.api_gateway_endpoint_name}"
}
