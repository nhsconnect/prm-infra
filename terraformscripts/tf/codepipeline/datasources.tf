data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "github_token" {
    name = "/NHS/${var.environment}-${data.aws_caller_identity.current.account_id}/tf/github_token"
}