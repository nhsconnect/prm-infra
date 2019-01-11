output "api_gw_endpoint" {
  value = "${module.apigw_endpoint.apigw_endpoint_public}"
}
