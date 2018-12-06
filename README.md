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
aws s3api create-bucket --bucket=prm-application-source --region=eu-west-2
git archive -o latest.zip HEAD 
aws s3 cp latest.zip s3://prm-application-source/source/latest.zip
cd lambda/ehr_extract_handler && zip ../../ehr_extract_handler main.js && cd -
aws s3 cp ehr_extract_handler.zip s3://prm-application-source/example.zip
terragrunt init
terragrunt apply
```

Caveat: make sure that your .terraform directory is empty or deleted when you run `terragrunt init`.

Type **yes** to build the infrastructure 

