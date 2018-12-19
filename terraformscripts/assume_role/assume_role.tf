resource "aws_iam_group" "developers-admin-access" {
  name = "developers_admin_access"
  path = "/users/"
}

resource "aws_iam_group_policy_attachment" "IAM-change-password" {
  group      = "${aws_iam_group.developers-admin-access.name}"
  policy_arn = "arn:aws:iam::aws:policy/IAMUserChangePassword"
}

resource "aws_iam_policy" "assume-role-dev-policy" {
  name   = "assume-role-dev-policy"
  policy = "${file("${path.module}/iam_role_policy_assume_role.json")}"
}

resource "aws_iam_group_policy_attachment" "assume-role-attachment" {
  group      = "${aws_iam_group.developers-admin-access.name}"
  policy_arn = "${aws_iam_policy.assume-role-dev-policy.arn}"
}

resource "aws_iam_policy" "enable-billing-dev-policy" {
  name   = "enable-billing-dev-policy"
  policy = "${file("${path.module}/iam_role_policy_enabe_billing.json")}"
}

resource "aws_iam_group_policy_attachment" "enable-billing-dev-policy" {
  group      = "${aws_iam_group.developers-admin-access.name}"
  policy_arn = "${aws_iam_policy.enable-billing-dev-policy.arn}"
}
