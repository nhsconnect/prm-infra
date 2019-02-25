#!/usr/bin/env bash

PIPELINE=$1

aws codepipeline list-pipeline-executions --region eu-west-2 --query "pipelineExecutionSummaries[]|[?starts_with(status, 'S')]" --pipeline-name $PIPELINE | \
  jq -r --arg pipeline $PIPELINE '.[]|[$pipeline, .startTime, .lastUpdateTime]|@tsv' | \
  awk '{printf("%s\t%f\t%f\n", $1, $2, $3 - $2)}' | \
  node main.js