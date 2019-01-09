resource "aws_api_gateway_rest_api" "ehr_extract_handler_api" {
  name = "EhrExtractHandlerApi"
}

output "base_url" {
  value = "${aws_api_gateway_deployment.api_gw_deployment.invoke_url}"
}

resource "aws_api_gateway_account" "demo" {
  cloudwatch_role_arn = "${aws_iam_role.cloudwatch-apigateway-log-role.arn}"
}

resource "aws_api_gateway_method_settings" "api_gw_method_settings" {
  rest_api_id = "${aws_api_gateway_rest_api.ehr_extract_handler_api.id}"
  stage_name  = "${aws_api_gateway_deployment.api_gw_deployment.stage_name}"
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "ERROR"
  }
}

resource "aws_api_gateway_deployment" "api_gw_deployment" {
  depends_on = [
    "aws_api_gateway_integration.send_integration",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.ehr_extract_handler_api.id}"
  stage_name  = "dev"
}

# /send
resource "aws_api_gateway_resource" "send" {
  rest_api_id = "${aws_api_gateway_rest_api.ehr_extract_handler_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.ehr_extract_handler_api.root_resource_id}"
  path_part   = "send"
}

resource "aws_api_gateway_method" "send_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.ehr_extract_handler_api.id}"
  resource_id   = "${aws_api_gateway_resource.send.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "send_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.ehr_extract_handler_api.id}"
  resource_id = "${aws_api_gateway_method.send_method.resource_id}"
  http_method = "${aws_api_gateway_method.send_method.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:eu-west-2:lambda:path/2015-03-31/functions/${aws_lambda_function.ehr_extract_handler.arn}/invocations"
}

# /status
resource "aws_api_gateway_resource" "status_parent" {
  rest_api_id = "${aws_api_gateway_rest_api.ehr_extract_handler_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.ehr_extract_handler_api.root_resource_id}"
  path_part   = "status"
}

resource "aws_api_gateway_resource" "status" {
  rest_api_id = "${aws_api_gateway_rest_api.ehr_extract_handler_api.id}"
  parent_id   = "${aws_api_gateway_resource.status_parent.id}"
  path_part   = "{uuid}"
}

resource "aws_api_gateway_method" "status_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.ehr_extract_handler_api.id}"
  resource_id   = "${aws_api_gateway_resource.status.id}"
  http_method   = "GET"
  authorization = "NONE"

  request_parameters {
    "method.request.path.uuid" = true
  }
}

resource "aws_api_gateway_integration" "status_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.ehr_extract_handler_api.id}"
  resource_id = "${aws_api_gateway_method.status_method.resource_id}"
  http_method = "${aws_api_gateway_method.status_method.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:eu-west-2:lambda:path/2015-03-31/functions/${aws_lambda_function.retrieve_status.arn}/invocations"
}

# /retrieve
resource "aws_api_gateway_resource" "retrieve_parent" {
  rest_api_id = "${aws_api_gateway_rest_api.ehr_extract_handler_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.ehr_extract_handler_api.root_resource_id}"
  path_part   = "retrieve"
}

resource "aws_api_gateway_resource" "retrieve" {
  rest_api_id = "${aws_api_gateway_rest_api.ehr_extract_handler_api.id}"
  parent_id   = "${aws_api_gateway_resource.retrieve_parent.id}"
  path_part   = "{uuid}"
}

resource "aws_api_gateway_method" "retrieve_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.ehr_extract_handler_api.id}"
  resource_id   = "${aws_api_gateway_resource.retrieve.id}"
  http_method   = "POST"
  authorization = "NONE"

  request_parameters {
    "method.request.path.uuid" = true
  }
}

resource "aws_api_gateway_integration" "retrieve_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.ehr_extract_handler_api.id}"
  resource_id = "${aws_api_gateway_method.retrieve_method.resource_id}"
  http_method = "${aws_api_gateway_method.retrieve_method.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:eu-west-2:lambda:path/2015-03-31/functions/${aws_lambda_function.retrieve_processed_ehr_extract.arn}/invocations"
}