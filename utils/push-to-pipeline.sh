#!/bin/bash


export ASSUME_ROLE_NAME=arn:aws:iam::431593652018:role/PASTASLOTHVULGAR
eval $(./utils/aws-cli-assumerole.sh -r $ASSUME_ROLE_NAME)

export TMP_DIR=$(mktemp -d)
zip -r -q $TMP_DIR/latest.zip *

echo Pushing s3://prm-application-source/source-walking-skeleton-spikes/latest.zip
aws s3 cp $TMP_DIR/latest.zip s3://prm-application-source/source-walking-skeleton-spikes/latest.zip

rm -Rf $TMP_DIR/latest.zip 
