#https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/

locals {
  cidr            = "10.0.0.0/16"
  public_subnets  = ["${cidrsubnet(local.cidr, 8, 0)}", "${cidrsubnet(local.cidr, 8, 1)}", "${cidrsubnet(local.cidr, 8, 2)}"]
  private_subnets = ["${cidrsubnet(local.cidr, 8, 4)}", "${cidrsubnet(local.cidr, 8, 5)}", "${cidrsubnet(local.cidr, 8, 6)}"]
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "prm-${var.environment}"
  cidr = "${local.cidr}"

  azs             = ["${var.availability_zones}"]
  public_subnets  = ["${slice(local.public_subnets, 0, length(var.availability_zones))}"]
  private_subnets = ["${slice(local.private_subnets, 0, length(var.availability_zones))}"]

  public_subnet_tags = {
    Name = "prm-${var.environment}-public-subnet"
  }

  private_subnet_tags = {
    Name = "prm-${var.environment}-private-subnet"
  }

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_dynamodb_endpoint = true
  enable_s3_endpoint       = true

  tags = {
    Environment = "prm-${var.environment}"
    Component   = "core"
  }
}

module "opentest_keypair" {
  source = "../modules/sshkeypair"

  name   = "vpn-gw-${var.environment}"
  bucket = "${var.secrets_bucket}"
}

module "opentest" {
  source = "../modules/opentest"

  aws_region  = "${var.aws_region}"
  environment = "${var.environment}"

  vpc_id                 = "${module.vpc.vpc_id}"
  vpc_cidr               = "${module.vpc.vpc_cidr_block}"
  vpc_private_subnet_ids = "${module.vpc.private_subnets}"
  vpc_availability_zones = "${module.vpc.azs}"
  opentest_assets_bucket = "${var.opentest_assets_bucket}"
  ssh_key_name           = "${module.opentest_keypair.name}"
}
