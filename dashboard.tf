resource "aws_cloudwatch_dashboard" "PRM-team-dashboard" {
  dashboard_name = "PRM-team-dashboard"

  dashboard_body = <<EOF
 {
   "widgets": [
       {
          "type":"metric",
          "x":0,
          "y":0,
          "properties":{
              "view": "timeSeries",
              "stacked": false,
              "metrics": [
                [ "AWS/ApiGateway", "Count", "ApiName", "EhrExtractHandlerApi" ],
                [ ".", "Latency", ".", "." ]
              ],
             "period":300,
             "stat":"Average",
             "region":"eu-west-2",
             "title":"EhrExtractHandler"
          }
       }
   ]
 }
 EOF
}