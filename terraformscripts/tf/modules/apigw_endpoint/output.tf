output "apigw_endpoint_id" {
  value = "${aws_api_gateway_rest_api.api_endpoint.id}"
}

output "apigw_endpoint_root_resource_id" {
  value = "${aws_api_gateway_rest_api.api_endpoint.root_resource_id}"
}

output "apigw_endpoint_name" {
  value = "${var.environment}-${var.api_gateway_endpoint_name}"
}

output "apigw_endpoint_public" {
  value = "https://${aws_api_gateway_rest_api.api_endpoint.id}.execute-api.${var.aws_region}.amazonaws.com/"
}
