resource "aws_api_gateway_rest_api" "api_endpoint" {
  name        = "${var.environment}-${var.api_gateway_endpoint_name}"
  description = "${var.environment}-${var.api_gateway_endpoint_name}"
}

resource "aws_api_gateway_account" "acc" {
  cloudwatch_role_arn = "${aws_iam_role.apigw_role.arn}"
}
