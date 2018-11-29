resource "aws_api_gateway_rest_api" "ehr-extract-handler-api" {
  name        = "EhrExtractHandlerApi"
  description = "Receives and sends GP2GP messages"
}

output "base_url" {
  value = "${aws_api_gateway_deployment.example.invoke_url}"
}
