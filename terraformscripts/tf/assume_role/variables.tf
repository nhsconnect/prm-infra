variable "aws_region" {
  default = "eu-west-2"
}

variable "role" {
  description = "name of the role to create"
}

variable "assume_only" {
  description = "1 for new account 0 for old account "
}

