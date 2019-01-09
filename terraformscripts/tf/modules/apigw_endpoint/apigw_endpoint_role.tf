resource "aws_api_gateway_account" "acc" {
  cloudwatch_role_arn = "${aws_iam_role.apigw_role.arn}"
}

data "template_file" "apigw_role" {
  template = "${file("${path.module}/apigw_endpoint_role.json")}"
}

data "template_file" "apigw_policy" {
  template = "${file("${path.module}/apigw_endpoint_policy.json")}"
}

resource "aws_iam_role_policy" "apigw_policy" {
  name_prefix = "apigw-${var.environment}-${var.api_gateway_endpoint_name}-"
  role        = "${aws_iam_role.apigw_role.id}"
  policy      = "${data.template_file.apigw_policy.rendered}"
}

resource "aws_iam_role" "apigw_role" {
  name_prefix        = "apigw-${var.api_gateway_endpoint_name}-${var.environment}-"
  assume_role_policy = "${data.template_file.apigw_role.rendered}"
}
