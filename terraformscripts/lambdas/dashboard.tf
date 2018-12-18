resource "aws_cloudwatch_dashboard" "PRM-team-dashboard" {
  dashboard_name = "PRM-team-dashboard"

  dashboard_body = <<EOF
 {
    "widgets": [
        {
            "type": "metric",
            "x": 6,
            "y": 6,
            "width": 6,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApiGateway", "Count", "ApiName", "EhrExtractHandlerApi" ]
                ],
                "period": 300,
                "stat": "Average",
                "region": "eu-west-2",
                "title": "EhrExtractHandlerCount"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 6,
            "width": 6,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApiGateway", "Latency", "ApiName", "EhrExtractHandlerApi" ]
                ],
                "period": 300,
                "stat": "Average",
                "region": "eu-west-2",
                "title": "EhrExtractHandlerLatency"
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 0,
            "width": 6,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApiGateway", "5XXError", "ApiName", "EhrExtractHandlerApi" ],
                    [ ".", "4XXError", ".", "." ]
                ],
                "period": 300,
                "stat": "Average",
                "region": "eu-west-2",
                "title": "EhrExtractHanderErrors"
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 0,
            "width": 6,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/Logs", "IncomingLogEvents", "LogGroupName", "API-Gateway-Execution-Logs_j4dbzo021j/dev" ]
                ],
                "period": 300,
                "stat": "Average",
                "region": "eu-west-2",
                "title": "ApiLogsMonitor"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 6,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/DynamoDB", "SuccessfulRequestLatency", "TableName", "PROCESS_STORAGE", "Operation", "PutItem" ]
                ],
                "region": "eu-west-2",
                "title": "DynamoDBWriteOperations"
            }
        }
    ]
}
 EOF
}
