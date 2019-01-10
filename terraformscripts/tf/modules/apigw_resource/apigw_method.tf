resource "aws_api_gateway_method" "method" {
  rest_api_id = "${var.apigw_endpoint_id}"
  resource_id = "${aws_api_gateway_resource.resource.id}"
  http_method = "${var.apigw_method_http_method}"
  authorization = "${var.apigw_method_authorisation}"
  request_parameters {
    "method.request.path.uuid" = true
  }
}

resource "aws_api_gateway_resource" "resource_parent" {
  rest_api_id = "${var.apigw_endpoint_id}"
  parent_id = "${var.apigw_endpoint_root_resource_id}"
  path_part = "${var.apigw_parent_path_part}"
}

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = "${var.apigw_endpoint_id}"
  parent_id = "${aws_api_gateway_resource.resource_parent.id}"
  path_part = "${var.apigw_path_part}"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id = "${var.apigw_endpoint_id}"
  resource_id = "${aws_api_gateway_resource.resource.id}"
  http_method = "${aws_api_gateway_method.method.http_method}"

  integration_http_method = "${aws_api_gateway_method.method.http_method}"
  type = "AWS_PROXY"
  uri = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${var.apigw_integration_lambda_function_arn}/invocations"
}

resource "aws_api_gateway_method_settings" "method_settings" {
  depends_on = ["aws_api_gateway_deployment.deployment"]
  rest_api_id = "${var.apigw_endpoint_id}"
  stage_name = "${aws_api_gateway_stage.stage.stage_name}"
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level = "ERROR"
  }
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    "aws_api_gateway_integration.integration",
    "aws_api_gateway_method.method"
  ]

  rest_api_id = "${var.apigw_endpoint_id}"
  stage_name = ""
}

resource "aws_api_gateway_stage" "stage" {
  stage_name = "${var.apigw_parent_path_part}"
  rest_api_id = "${var.apigw_endpoint_id}"
  deployment_id = "${aws_api_gateway_deployment.deployment.id}"

  provisioner "local-exec" {
    command = "sleep 5"
  }
}