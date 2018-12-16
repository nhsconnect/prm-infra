#!/bin/bash

export TMP_DIR=$(mktemp -d)

echo Assuming role
export ASSUME_ROLE_NAME=arn:aws:iam::431593652018:role/PASTASLOTHVULGAR
eval $(./utils/aws-cli-assumerole.sh -r $ASSUME_ROLE_NAME)

echo Cleaning up caches
find . -name ".terragrunt-cache" -type d -prune -exec rm -Rf "{}" \;
find . -name ".terraform" -type d -prune -exec rm -Rf "{}" \;


echo Creating artefacts $TMP_DIR/latest.zip
zip -r -q $TMP_DIR/latest.zip *

echo Pushing artefacts to s3://prm-application-source/source-walking-skeleton-spikes/latest.zip
aws s3 cp $TMP_DIR/latest.zip s3://prm-application-source/source-walking-skeleton-spikes/latest.zip

echo Removing cruft
rm -Rf $TMP_DIR 
