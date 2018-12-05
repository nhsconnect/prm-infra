terragrunt = {
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