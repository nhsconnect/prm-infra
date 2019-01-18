# Walking Skeleton
The purpose of this walking skeleton is to de-risk the technical uncertainty around creating a new live service for HSCN.

# Deploying the Skeleton to a new Environment

## Assumptions TBD
1. Create an AWS account
2. Create a user with permissions to edit all resource types
3. Export AWS credentials and save them in local aws profile
4. Make sure your AWS CLI works with the user from step 3

### Requirements
Install
- [terraform](https://www.terraform.io/)
- [terragrunt](https://github.com/gruntwork-io/terragrunt#install-terragrunt)

## Set Up Steps
 
### Create S3 bucket to hold lambda code
This will become the bucket to hold the application code used in lambdas

Run below commands
```console
git clone https://bitbucket.org/twnhsd/walking-skeleton-spikes.git
cd walking-skeleton-spikes

aws s3api create-bucket --bucket prm-application-source --region eu-west-2 --create-bucket-configuration LocationConstraint=eu-west-2
aws s3api put-bucket-versioning --bucket prm-application-source --versioning-configuration Status=Enabled
git archive -o latest.zip HEAD 
aws s3 cp latest.zip s3://prm-application-source/source/latest.zip
cd lambda/ehr_extract_handler && zip ../../ehr_extract_handler main.js && cd -
aws s3 cp ehr_extract_handler.zip s3://prm-application-source/example.zip
cd lambda/uptime_monitoring && zip ../../uptime_monitoring main.js && cd -
aws s3 cp uptime_monitoring.zip s3://uptime-monitoring-bucket/uptime_monitoring.zip
terragrunt init
terragrunt apply
```

Caveat: make sure that your .terraform directory is empty or deleted when you run `terragrunt init`.

Type **yes** to build the infrastructure 

### Adding an environment

1. Decide your environment name eg. live
2. Decide on the AWS account the environment is being deployed to eg. 1234567
3. Copy and paste terraformscripts/dev-431593652018 and rename appropriately eg. live-1234567
4. As a minimum you should leave the follwoing folders:
- apigw_lambda
- network
- opentest
Depending on what you want to setup/what functionality is required of the environment you may need the others.
5. Create secret in EC2 Parameter Key Store (based on /NHS/dev-431593652018/tf/opentest/ec2_keypair)
6. Run the following commands:
```console
cd utils
./create-environment.sh {env_name} {account_number}
```

### Security tokens

You will need to manage security tokens for the following:
- Github
- OpenTest

#### Managing GitHub
You gitub token is necessary to connect AWS CodePipeline to the Github Repositories

It is stored in AWS EC2 Parameter Store

The key will have the account and the environment name in and will look like:
`/NHS/dev-431593652018/tf/codepipeline/github-token` 
where `dev` is the environment and `431593652018` is the account.

You simply need to change the value in the affected key, or create a new key with that naming convention when setting up a new environment.

See [GitHubs documentation](https://help.github.com/articles/connecting-to-github-with-ssh/) for a step by step guide on setting up SSH keys.

## Known Problems
### Help! Im getting....
#### [ERROR] Error updating CodePipeline (xxxxxxx): InvalidActionDeclarationException: Action configuration for action 'XXXXXX' is missing required configuration 'OAuthToken'
This will happen anytime you wish to make a change to one of the 'aws_codepipeline' resources and where one of the sources of that pipeline is GitHub.

We currently don't manage secrets. And there are some 'issues' at the moment with GitHub Integration, AWS and Terraform, see https://github.com/terraform-providers/terraform-provider-aws/issues/2854.

At the top of the pipeline find the following code block:
```
  lifecycle {
    ignore_changes = [
      "stage.0.action.0.configuration.OAuthToken",
      "stage.0.action.0.configuration.%",
    ]
  }
```

and comment out the ignore changes, a la:
```
  lifecycle {
    ignore_changes = [
      #"stage.0.action.0.configuration.OAuthToken",
      #"stage.0.action.0.configuration.%",
    ]
  }
```

and commit this alongside your change to the pipeline.

Then revert the code back to its original state:
```
  lifecycle {
    ignore_changes = [
      "stage.0.action.0.configuration.OAuthToken",
      "stage.0.action.0.configuration.%",
    ]
  }
```
Sucks right. I know.