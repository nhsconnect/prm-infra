terragrunt = {
  terraform {
    extra_arguments "conditional_vars" {
      //      commands = [
      //        "apply",
      //        "plan",
      //        "import",
      //        "push",
      //        "refresh"
      //      ]

      required_var_files = [
        "${get_parent_tfvars_dir()}/environments/dev-intergration/dev-intergration.tfvars"
      ]
    }
  }
  remote_state {
    backend = "s3"
    config {
      bucket         = "prm-terraform-state"
      key            = "${path_relative_to_include()}/terraform.tfstate"
      region         = "eu-west-2"
      encrypt        = true
    }
  }
}

