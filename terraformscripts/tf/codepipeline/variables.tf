variable "environment" {
  description = "The name of the environment in which we're deploying"
}

variable "aws_region" {
  default = "eu-west-2"
}

variable "prm-application-source-bucket" {
  default = "dummy_bucket_value"
}

variable "codebuild-cache-bucket-name" {
  description = "Name of the S3 bucket that is supposed to hold cache information for CodeBuild"
}

variable "assume_role" {
  description = "whether or not to create user role in pipeline. Either 1 or 0"
}

variable "role_arn" {
  description = "role that codebuild will be able to assume"
}
