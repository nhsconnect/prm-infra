module "apigw_lambda_ehr_extract_handler" {
  source      = "../modules/lambda/"
  aws_region  = "${var.aws_region}"
  environment = "${var.environment}"
  lambda_name = "EhrExtractHandler"
  #vpc_id      = "${var.vpc_id}"
  #vpc_cidr    = "${var.vpc_cidr}"
}

module "apigw_lambda_uptime_monitoring" {
  source      = "../modules/lambda/"
  aws_region  = "${var.aws_region}"
  environment = "${var.environment}"
  lambda_name = "UptimeMonitoring"
  #vpc_id      = "${var.vpc_id}"
  #vpc_cidr    = "${var.vpc_cidr}"
}

module "apigw_lambda_retrieve_processed_ehr_extract" {
  source      = "../modules/lambda/"
  aws_region  = "${var.aws_region}"
  environment = "${var.environment}"
  lambda_name = "RetrieveProcessedEhrExtract"
  #vpc_id      = "${var.vpc_id}"
  #vpc_cidr    = "${var.vpc_cidr}"
}

module "apigw_lambda_retrieve_status" {
  source      = "../modules/lambda/"
  aws_region  = "${var.aws_region}"
  environment = "${var.environment}"
  lambda_name = "RetrieveStatus"
  #vpc_id      = "${var.vpc_id}"
  #vpc_cidr    = "${var.vpc_cidr}"
}
resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "PROCESS_STORAGE"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "PROCESS_ID"

 attribute = {
    name = "PROCESS_ID"
    type = "S"
  }
  
  server_side_encryption {
    enabled = true
  }
}
resource "aws_dynamodb_table" "test" {
  name           = "THUNDERBIRD"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "PROCESS_ID"

 attribute = {
    name = "PROCESS_ID"
    type = "S"
  }
  
  server_side_encryption {
    enabled = true
  }
}