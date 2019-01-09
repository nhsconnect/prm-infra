output "apigw_endpoint_id" {
  value = "${module.apigw_endpoint.apigw_endpoint_id}"
}

output "apigw_endpoint_root_resource_id" {
  value = "${module.apigw_endpoint.apigw_endpoint_root_resource_id}"
}

output "apigw_endpoint_name" {
  value = "${module.apigw_endpoint.apigw_endpoint_name}"
}

output "apigw_endpoint_public" {
  value = "https://${module.apigw_endpoint.apigw_endpoint_id}.execute-api.${var.aws_region}.amazonaws.com/"
}

