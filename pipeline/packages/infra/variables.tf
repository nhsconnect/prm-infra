variable "aws_region" {
  description = "The region in which the infrastructure will be deployed"
}

variable "environment" {
  description = "The name of the environment being deployed"
}

variable "github_token" {
  description = "The github token to use for authenticating"
}

variable "iam_role" {
  description = "The IAM role to use for provisioning"
}
