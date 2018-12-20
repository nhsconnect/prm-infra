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

## Additional
This code base is mirrored @ https://github.com/nhsconnect/prm-infra
Test

## Known Problems
### Help! Im getting....
#### InvalidActionDeclarationException: Action configuration for the new action 'GithubSource' contains an invalid configuration for the secret property 'OAuthToken'. '****' may be used in secret properties only when updating an existing action.
We currently don't manage secrets. So to resolve this:
- Change the OAuthToken value to `1234`
- Commit/Push
- Wait for the infrastructure to apply successfully
- Change the OAuthToken value to `****`
- Commit/Push
- Wait for the infrastructure to apply successfully
- In the AWS Console for CodePipeline, find the affected pipeline source stage, edit and authorise codepipeline as an application in github.