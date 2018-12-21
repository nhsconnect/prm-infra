resource "aws_iam_role" "codebuild-project-generic-role" {
  name               = "codebuild-project-generic-role"
  assume_role_policy = "${file("${path.module}/codebuild-project-generic-role.json")}"
}

# Assume-role policy for generic project role
resource "aws_iam_policy" "codebuild-project-generic-assume-role-policy" {
  name   = "codebuild-project-generic-assume-role-policy"
  policy = "${file("${path.module}/codebuild-project-generic-assume-role-policy.json")}"
}

resource "aws_iam_role_policy_attachment" "codebuild-project-generic-assume-role-attachment" {
  role       = "${aws_iam_role.codebuild-project-generic-role.name}"
  policy_arn = "${aws_iam_policy.codebuild-project-generic-assume-role-policy.arn}"
}

# Service policy for generic project role

resource "aws_iam_role_policy_attachment" "codebuild-project-generic-service-attachment" {
  role       = "${aws_iam_role.codebuild-project-generic-role.name}"
  policy_arn = "${aws_iam_policy.project-service-policy.arn}"
}
