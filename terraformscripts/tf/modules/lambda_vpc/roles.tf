data "template_file" "handler_role" {
  template = "${file("${path.module}/iam_role_lambda.json")}"
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "role_policy_lambda" {

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "dynamodb:*"
    ],
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
    ],
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter"
    ],
    resources = ["arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/NHS/${var.environment}-${data.aws_caller_identity.current.account_id}/lambda/${var.environment}-${var.lambda_name}/*"]
  }
}

resource "aws_iam_role_policy" "handler_policy" {
  name   = "${var.environment}-${var.lambda_name}"
  policy = "${data.aws_iam_policy_document.role_policy_lambda.json}"
  role   = "${aws_iam_role.handler_role.id}"
}

resource "aws_iam_role" "handler_role" {
  name               = "${var.environment}-${var.lambda_name}"
  assume_role_policy = "${data.template_file.handler_role.rendered}"
}
