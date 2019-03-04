resource "aws_lambda_function" "handler" {
  function_name = "${var.environment}-${var.lambda_name}"
  filename      = "${path.module}/lambda.zip"
  handler       = "${var.lambda_handler}"
  runtime       = "${var.lambda_runtime}"
  role          = "${aws_iam_role.handler_role.arn}"
  timeout       = 5

  vpc_config {
    subnet_ids  = ["${split(",", var.private_subnet_ids)}"]
    security_group_ids = ["${aws_security_group.allowopentest.id}"]
  }

  environment {
    variables = "${var.lambda_environment_variables}"
  }
}
