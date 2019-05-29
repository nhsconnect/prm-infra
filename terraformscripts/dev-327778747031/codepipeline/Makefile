.PHONY : deploy destroy init reinit

deploy : output.json

output.json : terraform.tfvars ../../tf/codepipeline/* | .terragrunt-cache
	terragrunt apply --terragrunt-non-interactive -no-color -auto-approve -var github_token=$$(MSYS_NO_PATHCONV=1 aws ssm get-parameter --name "/NHS/dev-327778747031/tf/github_token" --query Parameter.Value --output text --with-decryption)
	terragrunt output -no-color -json > output.json

destroy :
	terragrunt destroy --terragrunt-non-interactive -no-color -auto-approve
	rm -rf output.json

init : .terragrunt-cache

.terragrunt-cache :
	terragrunt init

reinit :
	terragrunt init --terragrunt-source-update