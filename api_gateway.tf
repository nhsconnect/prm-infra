resource "aws_api_gateway_rest_api" "ehr_extract_handler_api" {
  name        = "EhrExtractHandlerApi"
  description = "Terraform Serverless Application Example"
}

output "base_url" {
  value = "${aws_api_gateway_deployment.example.invoke_url}"
}
