data "template_file" "handler_role" {
  template = "${file("${path.module}/iam_role_lambda.json")}"
}

data "template_file" "handler_policy" {
  template = "${file("${path.module}/iam_role_policy_lambda.json")}"
}

resource "aws_iam_role_policy" "handler_policy" {
  name   = "${var.environment}-${var.lambda_name}"
  policy = "${data.template_file.handler_policy.rendered}"
  role   = "${aws_iam_role.handler_role.id}"
}

resource "aws_iam_role" "handler_role" {
  name               = "${var.environment}-${var.lambda_name}"
  assume_role_policy = "${data.template_file.handler_role.rendered}"
}
