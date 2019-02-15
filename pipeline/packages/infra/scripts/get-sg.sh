#!/usr/bin/env sh

## This is all done using the AWS CLI as Terraform doesn't know about the VPC until after the build has run

EXISTING_SG=$(aws ec2 describe-security-groups --filters Name=vpc-id,Values=${VPC_ID},Name=group-name,Values=infra-pipeline-test-${ENVIRONMENT}-sg --query=SecurityGroups[0].GroupId --output text)
if [[ "${EXISTING_SG}" == "None" ]]; then
  EXISTING_SG=$(aws ec2 create-security-group --description="CodePipeline Test SG for ${ENVIRONMENT}" --group-name="infra-pipeline-test-${ENVIRONMENT}-sg" --vpc-id=${VPC_ID} --query GroupId --output text)
fi
echo $EXISTING_SG