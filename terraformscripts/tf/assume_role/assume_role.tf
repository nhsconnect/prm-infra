resource "aws_iam_group" "developers-admin-access" {
  name = "developers_admin_access"
  path = "/users/"
  count = "${var.assume_only==0?1:0}"
}

resource "aws_iam_group_policy_attachment" "IAM-change-password" {
  group      = "${aws_iam_group.developers-admin-access.name}"
  policy_arn = "arn:aws:iam::aws:policy/IAMUserChangePassword"
  count = "${var.assume_only==0?1:0}"
}

resource "aws_iam_role" "codebuild-role" {
  name = "${var.role}"
  count = "${var.assume_only}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      },
      "Effect": "Allow"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "codebuild-role" {
  role = "${aws_iam_role.codebuild-role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  count = "${var.assume_only}"
}


data "template_file" "assume-role-dev-policy" {
  template = "${file("${path.module}/iam_role_policy_assume_role.json")}"
  vars = {
    ROLE = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.role}"
  }
}

data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "assume-role-dev-policy" {
  name   = "assume-role-dev-policy"
  policy = "${data.template_file.assume-role-dev-policy.rendered}"
}

resource "aws_iam_group_policy_attachment" "assume-role-attachment" {
  group      = "${aws_iam_group.developers-admin-access.name}"
  policy_arn = "${aws_iam_policy.assume-role-dev-policy.arn}"
  count = "${var.assume_only==0?1:0}"
}

resource "aws_iam_policy" "enable-billing-dev-policy" {
  name   = "enable-billing-dev-policy"
  policy = "${file("${path.module}/iam_role_policy_enabe_billing.json")}"
  count = "${var.assume_only==0?1:0}"
}

resource "aws_iam_group_policy_attachment" "enable-billing-dev-policy" {
  group      = "${aws_iam_group.developers-admin-access.name}"
  policy_arn = "${aws_iam_policy.enable-billing-dev-policy.arn}"
  count = "${var.assume_only==0?1:0}"  
}
