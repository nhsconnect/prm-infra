# DEPRECATED

This repository should be considered deprecated and will receive no further updates. It is not tied to any live systems or service and so will not receive updates of any kind. It is for information purposes only.

If you wish to discuss this repository please contact the Patient Record Migration (PRM) team in GPITFutures.

# Walking Skeleton
The purpose of this walking skeleton is to de-risk the technical uncertainty around creating a new live service for HSCN.

## Deploying the Skeleton to a new Environment

### Requirements
Install and ensure available on path
- [terraform](https://www.terraform.io/) v0.11.11
- [terragrunt](https://github.com/gruntwork-io/terragrunt#install-terragrunt) v0.17.4
- bash [on windows](https://gitforwindows.org/)
- make [on windows](https://sourceforge.net/projects/ezwinports/files/make-4.2.1-without-guile-w32-bin.zip/download)
- [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)

## Pre-requisites
Upload secrets into SSM Parameter Store for:
- `/NHS/dev-327778747031/lambda/dev-Translator/pds_private_key.pem` - private key for accessing Spine services on OpenTest
- `/NHS/dev-327778747031/tf/codepipeline/client_private_key.pem` - private key for accessing Spine services on OpenTest
- `/NHS/dev-327778747031/tf/github_token` - github personal access token for access to repositories
- `/NHS/dev-327778747031/tf/opentest/ec2_keypair` - SSH public key to use for OpenTest Gateway Host
- `/NHS/dev-327778747031/tf/opentest/ec2_keypair_private` - SSH private key to use for OpenTest Gateway Host
- `/NHS/dev-327778747031/tf/secscan/slack-url` - URL to use for bot to use for Slack notification of security incident

Upload into `prm-327778747031-opentest-assets` S3 bucket:
- VPN configuration for OpenTest provided by service desk

## Set Up Steps
 
- Ensure your AWS setup is configured to allow access to account `327778747031`
- Run `make` in the root of the project
- When build completes login in the AWS console and select `Code Pipeline`
- Wait for `prm-images-pipeline` to complete
- The `prm-servinginfra-pipeline` will have failed as it requires images from the `prm-images-pipeline` - open the pipeline and click `Retry` on the `Build Network` stage
- Wait for `prm-servinginfra-pipeline` to complete
- The `prm-lambda-pipeline` will have failed as it depends on `prm-images-pipeline` - open the pipeline and click `Retry` on the `Scan dependencies` stage

# Deprovision steps

- Open the AWS console and select `Code Pipeline`
- Select the `prm-servinginfra-pipeline` and approve the `Approve Infra Destruction` stage
- Wait for the `prm-servinginfra-pipeline` to complete
- Ensure your AWS setup is configured to allow access to account `327778747031`
- Run `make destroy` in the root of the project