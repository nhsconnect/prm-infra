# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# This is the configuration for Terragrunt, a thin wrapper for Terraform that supports locking and enforces best
# practices: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

terragrunt = {
  # Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
  # working directory, into a temporary folder, and execute your Terraform commands in that folder.
  terraform {
    source = "../..//tf/codepipeline"
  }

  iam_role = "arn:aws:iam::431593652018:role/PASTASLOTHVULGAR"

  dependencies {
    paths = ["../assume_role"]
  }

  # Include all settings from the root terraform.tfvars.old.old file
  #include = {
  #  path = "${find_in_parent_folders()}"
  # }

  extra_arguments "conditional_vars" {

    commands = [
      "validate",
      "plan",
      "apply"
    ]

  #  arguments = [
  #    "-var",
  #    "prm-application-source-bucket=prm-application-source"
  #  ]
  }

  remote_state {
    backend = "s3"
    config {
      bucket = "prm-431593652018-terraform-states"
      key = "codepipeline/terraform.tfstate"
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

prm-application-source-bucket = "prm-application-source"
