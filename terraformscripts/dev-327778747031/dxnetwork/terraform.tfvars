# TERRAGRUNT CONFIGURATION
# This is the configuration for Terragrunt, a thin wrapper for Terraform that supports locking and enforces best
# practices: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

terragrunt = {
  # Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
  # working directory, into a temporary folder, and execute your Terraform commands in that folder.
  terraform {
    source = "../..//tf/dxnetwork"
  }

  dependencies {
    paths = []
  }

  remote_state {
    backend = "s3"
    config {
      bucket = "prm-327778747031-terraform-states"
      key = "dev/dxnetwork/terraform.tfstate"
      region = "eu-west-2"
      encrypt = true
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
# ---------------------------------------------------------------------------------------------------------------------

aws_region                  = "eu-west-2"
availability_zones          = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
stage                       = "dev"
vpc_cidr                    = "10.239.68.128/25"
vpn_gateway_amazon_side_asn = "64512"
dx_gateway_owner_account_id = "128228465374"
dx_gateway_id               = "5a60ce93-0147-47b3-91a5-00d863678f02"