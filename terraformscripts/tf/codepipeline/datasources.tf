data "aws_caller_identity" "current" {}

locals {
    assumed_role = "${data.aws_caller_identity.current.arn}"
    assumed_role_components = ["${split(":", local.assumed_role)}"]
    role_name = "${local.assumed_role_components[5]}"
    role_name_components = ["${split("/", local.role_name)}"]
    role = "arn:aws:iam::${local.assumed_role_components[4]}:role/${local.role_name_components[1]}"
}