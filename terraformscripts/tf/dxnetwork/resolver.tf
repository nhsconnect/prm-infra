resource "aws_security_group" "resolver" {
  name   = "${module.vpc_label_resolver.id}"
  tags   = "${module.vpc_label_resolver.tags}"
  vpc_id = "${module.vpc.vpc_id}"

  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_route53_resolver_endpoint" "hscn" {
  direction = "OUTBOUND"
  name      = "${module.vpc_label_resolver.id}"
  tags      = "${module.vpc_label_resolver.tags}"
  security_group_ids = ["${aws_security_group.resolver.id}"]

  ip_address {
    subnet_id = "${element(module.vpc.private_subnets, 0)}"
  }
  ip_address {
    subnet_id = "${element(module.vpc.private_subnets, 1)}"
  }
  ip_address {
    subnet_id = "${element(module.vpc.private_subnets, 2)}"
  }
}
resource "aws_route53_resolver_rule" "nhs_uk" {
  domain_name          = "nhs.uk"
  name                 = "nhs_uk"
  rule_type            = "FORWARD"
  resolver_endpoint_id = "${aws_route53_resolver_endpoint.hscn.id}"
  tags                 = "${module.vpc_label_resolver.tags}"

  target_ip {
      ip = "${element(var.dns_server_ip_addresses, 0)}"
  }

  target_ip {
      ip = "${element(var.dns_server_ip_addresses, 1)}"
  }
}

