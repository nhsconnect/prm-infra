module "apigw_lambda_ehr_extract_handler" {
  source     = "../modules/lambda/"
  aws_region = "${var.aws_region}"

  environment = "${var.environment}"

  lambda_name = "EhrExtractHandler"
}
