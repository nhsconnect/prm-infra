#resource "aws_iam_role" "assume-role-dev" {
#  name = "assume-role-dev"
#
#  assume_role_policy = <<EOF
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Action": "sts:AssumeRole",
#      "Effect": "Allow",
#      "Principal": { "AWS": "arn:aws:iam::431593652018:root" },
#      "Sid": ""
#    }
#  ]
#}
#EOF
#}

resource "aws_iam_group" "developers" {
  name = "developers"
  path = "/users/"
}

resource "aws_iam_group_policy_attachment" "assume-role-attachment" {
  group = "${aws_iam_group.developers.name}"
  policy_arn = "${aws_iam_policy.assume-role-dev-policy.arn}"
}

resource "aws_iam_group_policy_attachment" "IAM-change-password" {
  group = "${aws_iam_group.developers.name}"
  policy_arn = "arn:aws:iam::aws:policy/IAMUserChangePassword"
}

resource "aws_iam_policy" "assume-role-dev-policy" {
  name = "assume-role-dev-policy"
  # role = "${aws_iam_role.assume-role-dev.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Resource": ["arn:aws:iam::431593652018:role/PASTASLOTHVULGAR"]
    }
}

EOF
}
