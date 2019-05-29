.PHONY : deploy destroy init reinit

deploy : output.json

output.json : terraform.tfvars ../../tf/assume_role/* | .terragrunt-cache 
	terragrunt apply --terragrunt-non-interactive -no-color -auto-approve
	terragrunt output -no-color -json > output.json

destroy :
	terragrunt destroy --terragrunt-non-interactive -no-color -auto-approve
	rm -rf output.json

init : .terragrunt-cache

.terragrunt-cache :
	terragrunt init

reinit :
	terragrunt init --terragrunt-source-update