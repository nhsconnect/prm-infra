resource "aws_cloudwatch_dashboard" "PRM-team-dashboard" {
  dashboard_name = "PRM-team-dashboard-${var.environment}"

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
                    [ "AWS/ApiGateway", "Count", "ApiName", "${var.environment}-EhrExtractHandlerApi" ]
                ],
                "period": 300,
                "stat": "Average",
                "region": "${var.aws_region}",
                "title": "${var.environment}-EhrExtractHandlerCount"
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
                    [ "AWS/ApiGateway", "Latency", "ApiName", "${var.environment}-EhrExtractHandlerApi" ]
                ],
                "period": 300,
                "stat": "Average",
                "region": "${var.aws_region}",
                "title": "${var.environment}-EhrExtractHandlerLatency"
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
                    [ "AWS/ApiGateway", "5XXError", "ApiName", "${var.environment}-EhrExtractHandlerApi" ],
                    [ ".", "4XXError", ".", "." ]
                ],
                "period": 300,
                "stat": "Average",
                "region": "${var.aws_region}",
                "title": "${var.environment}-EhrExtractHanderErrors"
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
                "region": "${var.aws_region}",
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
                "region": "${var.aws_region}",
                "title": "DynamoDBWriteOperations"
            }
        }
    ]
}
 EOF
}
