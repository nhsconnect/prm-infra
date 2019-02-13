terragrunt = {
  terraform {
    source = "../../../packages//core"
  }

  iam_role = "arn:aws:iam::431593652018:role/PASTASLOTHVULGAR"

  dependencies {
    paths = []
  }

  extra_arguments "no_color" {
    arguments = [
      "-no-color"
    ]
    commands = [
      "init",
    ]
  }

  remote_state {
    backend = "s3"
    config {
      bucket = "prm-431593652018-terraform-states"
      key = "dev/core/terraform.tfstate"
      region = "eu-west-2"
      encrypt = true
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
# ---------------------------------------------------------------------------------------------------------------------

aws_region = "eu-west-2"
environment = "dev"
availability_zones = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
opentest_assets_bucket = "prm-431593652018-opentest-assets"
secrets_bucket = "dfkjhdsjkgsdfjgkjsfdkgjfsdnkjgsdf"
