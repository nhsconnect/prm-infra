#!/usr/bin/env bash

aws codepipeline list-pipelines --region eu-west-2 --query 'pipelines[].name' --output text | \
 xargs -n1 aws codepipeline get-pipeline --region eu-west-2 --query 'pipeline.stages[].actions[?actionTypeId.provider==`CodeBuild`].configuration.ProjectName[]' --output text --name | \
 xargs -n1 aws codebuild list-builds-for-project --query 'ids[]' --region eu-west-2 --output text --project-name | \
 xargs -n100 aws codebuild batch-get-builds --query 'builds[?buildStatus==`SUCCEEDED`].[projectName, startTime, endTime]' --region eu-west-2 --output text --ids | \
 awk '{printf("%s\t%f\t%f\n", $1, $2, $3 - $2)}' | \
 node main.js