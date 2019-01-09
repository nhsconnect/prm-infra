resource "aws_api_gateway_method" "method" {
  rest_api_id = "${var.apigw_endpoint_id}"
  resource_id = "${aws_api_gateway_resource.resource.id}"
  http_method = "${var.apigw_method_http_method}"
  authorization = "${var.apigw_method_authorisation}"
}

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = "${var.apigw_endpoint_id}"
  parent_id = "${var.apigw_endpoint_root_resource_id}"
  path_part = "${var.apigw_path_part}"
}
