#pipeline_infra
resource "aws_iam_role_policy_attachment" "project-service-infra-plan-attach" {
  role       = "${aws_iam_role.codebuild-prm-infra-plan-role.name}"
  policy_arn = "${aws_iam_policy.project-service-policy.arn}"
}

resource "aws_iam_role_policy_attachment" "project-service-infra-apply-attach" {
  role       = "${aws_iam_role.codebuild-prm-infra-apply-role.name}"
  policy_arn = "${aws_iam_policy.project-service-policy.arn}"
}

resource "aws_iam_role_policy_attachment" "project-service-infra-validate-attach" {
  role       = "${aws_iam_role.codebuild-prm-infra-validate-role.name}"
  policy_arn = "${aws_iam_policy.project-service-policy.arn}"
}

#pipeline_lambda
resource "aws_iam_role_policy_attachment" "project-service-lambda-build-attach" {
  role       = "${aws_iam_role.codebuild-lambda-build-role.name}"
  policy_arn = "${aws_iam_policy.project-service-policy.arn}"
}

resource "aws_iam_policy" "project-service-policy" {
  name = "project-service-policy"

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
     {
       "Effect": "Allow",
       "Action": [
         "s3:*",
         "logs:*",
         "iam:*"
       ],
       "Resource": "*"
     }
   ]
 }
EOF
}
