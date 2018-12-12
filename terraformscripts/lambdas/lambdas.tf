resource "aws_lambda_function" "ehr_extract_handler" {
  function_name = "EhrExtractHandler"

  //  s3_bucket     = "${var.prm-application-source-bucket}"
  //  s3_key        = "example.zip"
  filename = "${path.root}/example.zip"

  handler = "main.handler"
  runtime = "nodejs8.10"
  role    = "${aws_iam_role.lambda_exec.arn}"
}

resource "aws_lambda_function" "uptime_monitoring" {
  function_name = "UptimeMonitoring"

  //  s3_bucket     = "${aws_s3_bucket.uptime_monitoring_bucket.bucket}"
  //  s3_key        = "uptime_monitoring.zip"
  filename = "${path.root}/example.zip"

  //  source_code_hash = "${base64sha256(format("%s/example.zip", path.root))}"
  handler = "main.handler"
  runtime = "nodejs8.10"
  role    = "${aws_iam_role.lambda_exec.arn}"

  environment {
    variables = {
      url   = "${aws_api_gateway_deployment.api_gw_deployment.invoke_url}"
      stage = "${aws_api_gateway_deployment.api_gw_deployment.stage_name}"
    }
  }
}
