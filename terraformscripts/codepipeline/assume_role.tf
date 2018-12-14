




resource "aws_iam_role_policy_attachment" "infra-plan-attach" {
  role       = "${aws_iam_role.codebuild-prm-infra-plan-role.name}"
  policy_arn = "${aws_iam_policy.assume-role-codepipeline-policy.arn}"
}

resource "aws_iam_role_policy_attachment" "infra-apply-attach" {
  role       = "${aws_iam_role.codebuild-prm-infra-apply-role.name}"
  policy_arn = "${aws_iam_policy.assume-role-codepipeline-policy.arn}"
}

resource "aws_iam_role_policy_attachment" "infra-validate-attach" {
  role       = "${aws_iam_role.codebuild-prm-infra-validate-role.name}"
  policy_arn = "${aws_iam_policy.assume-role-codepipeline-policy.arn}"
}


resource "aws_iam_policy" "assume-role-codepipeline-policy" {
  name = "assume-role-codepipeline-policy"

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
