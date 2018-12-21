output "Build steps temporary artefacts bucket" {
  value = "${aws_s3_bucket.prm-codebuild-lambda-artifact.arn}"
}
