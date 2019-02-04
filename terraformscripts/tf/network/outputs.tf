output "vpc_id" {
  value = "${module.network.vpc_id}"
}

output "vpc_cidr" {
  value = "${module.network.vpc_cidr_block}"
}

output "vpc_subnet_public_ids" {
  value = "${join(",", module.network.public_subnets)}"
}

output "vpc_subnet_public_cidrs" {
  value = "${join(",", module.network.public_subnets_cidr_blocks)}"
}

output "vpc_subnet_private_ids" {
  value = "${join(",", module.network.private_subnets)}"
}

output "vpc_subnet_private_cidrs" {
  value = "${join(",", module.network.private_subnets_cidr_blocks)}"
}

output "vpc_egress_all_security_group" {
  value = "${aws_security_group.egress_all_security_group.id}"
}
