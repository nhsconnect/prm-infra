//terragrunt = {
//  terraform {
//    extra_arguments "conditional_vars" {
//
//      commands = [
//        "validate",
//        "plan",
//        "apply"
//      ]
//
//      arguments = [
//        "-var", "prm-application-source-bucket=prm-application-source"
//      ]
//    }
//  }
//  remote_state {
//    backend = "s3"
//    config {
//      bucket         = "prm-terraform-state"
//      key            = "${path_relative_to_include()}/terraform.tfstate"
//      region         = "eu-west-2"
//      encrypt        = true
//    }
//  }
//}
prm-application-source-bucket = "prm-application-source"
