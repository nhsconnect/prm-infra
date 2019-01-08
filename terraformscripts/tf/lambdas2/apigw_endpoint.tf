resource "aws_api_gateway_rest_api" "api_endpoint" {
  name        = "${var.environment}-${var.api_gateway_endpoint_name}"
  description = "${var.environment}-${var.api_gateway_endpoint_name}"
}
