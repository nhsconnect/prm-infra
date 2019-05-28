#https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/

locals {
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

module "network" {
  source = "terraform-aws-modules/vpc/aws"
  version = "1.66.0"

  name = "${var.environment}-network"
  cidr = "10.0.0.0/16"

  azs             = ["${var.availability_zones}"]
  public_subnets  = "${slice(local.public_subnets, 0, length(var.availability_zones))}"
  private_subnets = "${slice(local.private_subnets, 0, length(var.availability_zones))}"

  public_subnet_tags = {
    Name = "${var.environment}-public-subnet"
  }

  private_subnet_tags = {
    Name = "${var.environment}-private-subnet"
  }

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_dynamodb_endpoint = true

  tags = {
    Environment = "${var.environment}"
    Component   = "network"
  }
}

resource "aws_security_group" "egress_all_security_group" {
  name        = "${var.environment}-egress-all"
  description = "Allow outgoing traffic to anywhere"
  vpc_id      = "${module.network.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-egress-all"
    Environment = "${var.environment}"
    Component   = "network"
  }
}