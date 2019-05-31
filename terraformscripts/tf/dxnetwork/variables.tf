variable "vpc_cidr" {
  description = "The CIDR block to assign to the VPC"
}

variable "aws_region" {
  description = "The AWS region that the VPC will be deployed in"
}

variable "availability_zones" {
  description = "The availability zones that subnets will be provisioned in, must be in the specified region: at most 3 zones can be specified"
  type        = "list"
}

variable "stage" {
  description = "The stage, e.g. prod, test, dev"
}

variable "vpn_gateway_amazon_side_asn" {
  description = "The BGP autonomous system number to associate with the VPN gateway"
}

variable "dx_gateway_owner_account_id" {
  description = "The id of the AWS account that owns the DX gateway"
}

variable "dx_gateway_id" {
  description = "The id of the DX gateway to associate with (must be provisioned in the dx_gateway_account_id)"
}
