variable "aws_region" {
  default = "eu-west-2"
}

variable "prm-application-source-bucket" {
  default = "dummy_bucket_value"
}

variable "github_token" {
  default = "dummy_token_value"
}

variable "codebuild-cache-bucket-name" {}
variable "assume_role" {
  description = "whether or not to create user role in pipeline. Either 1 or 0"
}
