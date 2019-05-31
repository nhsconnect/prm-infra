resource "aws_dx_gateway_association_proposal" "hscn" {
  dx_gateway_id               = "${var.dx_gateway_id}"
  dx_gateway_owner_account_id = "${var.dx_gateway_owner_account_id}"
  associated_gateway_id       = "${module.vpc.vgw_id}"
}
