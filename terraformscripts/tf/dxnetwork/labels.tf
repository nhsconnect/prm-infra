module "vpc_label" {
  source    = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=master"
  namespace = "prm"
  stage     = "${var.stage}"
  name      = "dxnetwork"
}

module "vpc_label_public" {
  source     = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=master"
  namespace  = "${module.vpc_label.namespace}"
  stage      = "${module.vpc_label.stage}"
  name       = "${module.vpc_label.name}"
  attributes = ["public"]
  tags       = "${map("Network", "public")}"
}

module "vpc_label_private" {
  source     = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=master"
  namespace  = "${module.vpc_label.namespace}"
  stage      = "${module.vpc_label.stage}"
  name       = "${module.vpc_label.name}"
  attributes = ["private"]
  tags       = "${map("Network", "private")}"
}

module "vpc_label_vpngw" {
  source     = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=master"
  namespace  = "${module.vpc_label.namespace}"
  stage      = "${module.vpc_label.stage}"
  name       = "${module.vpc_label.name}"
  attributes = ["hscn"]
  tags       = "${map("Target", "hscn")}"
}

module "vpc_label_resolver" {
  source     = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=master"
  namespace  = "${module.vpc_label.namespace}"
  stage      = "${module.vpc_label.stage}"
  name       = "${module.vpc_label.name}"
  attributes = ["hscn"]
  tags       = "${map("Target", "hscn")}"
}
