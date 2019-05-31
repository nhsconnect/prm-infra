locals {
  private_subnets = ["${cidrsubnet(var.vpc_cidr, 2, 0)}", "${cidrsubnet(var.vpc_cidr, 2, 1)}", "${cidrsubnet(var.vpc_cidr, 2, 2)}"]
  public_subnets  = ["${cidrsubnet(var.vpc_cidr, 2, 3)}"]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.66.0"

  name = "${module.vpc_label.id}"
  cidr = "${var.vpc_cidr}"
  azs  = ["${var.availability_zones}"]
  tags = "${module.vpc_label.tags}"

  private_subnets                    = "${slice(local.private_subnets, 0, length(var.availability_zones))}"
  private_subnet_tags                = "${module.vpc_label_private.tags}"
  private_route_table_tags           = "${module.vpc_label_private.tags}"
  propagate_private_route_tables_vgw = true

  enable_nat_gateway     = false
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  amazon_side_asn    = "${var.vpn_gateway_amazon_side_asn}"
  enable_vpn_gateway = true
  vpn_gateway_tags   = "${module.vpc_label_vpngw.tags}"

  enable_dns_hostnames = true
  enable_dns_support   = true
}

# Define public subnet
resource "aws_internet_gateway" "internet" {
  vpc_id = "${module.vpc.vpc_id}"
  tags   = "${module.vpc_label_public.tags}"
}

resource "aws_subnet" "public" {
  count                   = "${length(local.public_subnets)}"
  vpc_id                  = "${module.vpc.vpc_id}"
  availability_zone       = "${element(var.availability_zones, count.index)}"
  cidr_block              = "${element(local.public_subnets, count.index)}"
  map_public_ip_on_launch = true
  tags                    = "${module.vpc_label_public.tags}"
}

resource "aws_route_table" "public" {
  vpc_id = "${module.vpc.vpc_id}"
  tags   = "${module.vpc_label_public.tags}"
}

resource "aws_route" "public_route_igw" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.internet.id}"
}

resource "aws_vpn_gateway_route_propagation" "public" {
  vpn_gateway_id = "${module.vpc.vgw_id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "public" {
  count          = "${length(local.public_subnets)}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

