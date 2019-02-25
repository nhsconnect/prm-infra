#!/usr/bin/env bash

PIPELINE=$1

aws codepipeline get-pipeline --name $PIPELINE --region eu-west-2 --query 'pipeline.stages[].actions[?actionTypeId.provider==`CodeBuild`].configuration.ProjectName[]' --output text | \
 xargs -n1 aws codebuild list-builds-for-project --query 'ids[]' --region eu-west-2 --output text --project-name | \
 xargs -n100 aws codebuild batch-get-builds --query 'builds[?buildStatus==`SUCCEEDED`].[projectName, startTime, endTime]' --region eu-west-2 --output text --ids | \
 awk '{printf("%s\t%f\t%f\n", $1, $2, $3 - $2)}' | \
 node main.js