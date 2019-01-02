output "Build_steps_temporary_artefacts_bucket" {
  value = "${aws_s3_bucket.prm-codebuild-lambda-artifact.arn}"
}
