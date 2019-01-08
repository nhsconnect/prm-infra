resource "aws_lambda_function" "handler" {
  function_name = "${var.environment}-${var.lambda_name}"
  filename = "${path.module}/lambda.zip"
  handler = "${var.lambda_handler}"
  runtime = "${var.lambda_runtime}"
  role = "${aws_iam_role.handler_role.arn}"
}
