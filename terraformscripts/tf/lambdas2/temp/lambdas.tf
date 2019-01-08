resource "aws_lambda_function" "ehr_extract_handler" {
  function_name = "EhrExtractHandler"

  #  s3_bucket     = "${var.prm-application-source-bucket}"
  #  s3_key        = "example.zip"
  filename = "${path.root}/dummy_ehr_extract_handler.zip"

  # source_code_hash = "${base64sha256(format("%s/dummy_ehr_extract_handler.zip", path.root))}"

  handler = "main.handler"
  runtime = "nodejs8.10"
  role    = "${aws_iam_role.lambda_exec.arn}"
}

resource "aws_lambda_function" "uptime_monitoring" {
  function_name = "UptimeMonitoring"

  #  s3_bucket     = "${aws_s3_bucket.uptime_monitoring_bucket.bucket}"
  #  s3_key        = "uptime_monitoring.zip"
  filename = "${path.root}/dummy_uptime_monitoring.zip"

  # source_code_hash = "${base64sha256(format("%s/dummy_uptime_monitoring.zip", path.root))}"

  handler = "main.handler"
  runtime = "nodejs8.10"
  role    = "${aws_iam_role.lambda_exec.arn}"
  environment {
    variables = {
      url      = "${aws_api_gateway_deployment.api_gw_deployment.invoke_url}"
      stage    = "${aws_api_gateway_deployment.api_gw_deployment.stage_name}"
      endpoint = "${aws_api_gateway_resource.send.path_part}"
    }
  }
}

resource "aws_lambda_function" "retrieve_status" {
  function_name = "RetrieveStatus"
  filename      = "${path.root}/dummy_retrieve_status.zip"

  # source_code_hash = "${base64sha256(format("%s/dummy_uptime_monitoring.zip", path.root))}"

  handler = "main.handler"
  runtime = "nodejs8.10"
  role    = "${aws_iam_role.lambda_exec.arn}"
}

resource "aws_lambda_function" "retrieve_processed_ehr_extract" {
  function_name = "RetrieveProcessedEhrExtract"
  filename      = "${path.root}/dummy_retrieve_processed_ehr_extract.zip"
  handler       = "main.handler"
  runtime       = "nodejs8.10"
  role          = "${aws_iam_role.lambda_exec.arn}"
}
