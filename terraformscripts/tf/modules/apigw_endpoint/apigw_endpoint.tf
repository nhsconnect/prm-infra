resource "aws_api_gateway_rest_api" "api_endpoint" {
  name        = "${var.environment}-${var.api_gateway_endpoint_name}"
  description = "${var.environment}-${var.api_gateway_endpoint_name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "execute-api:Invoke",
            "Resource": "arn:aws:execute-api:eu-west-2:327778747031:aa826k16a9/*/*/*"
        },
        {
            "Effect": "Deny",
            "Principal": "*",
            "Action": "execute-api:Invoke",
            "Resource": "arn:aws:execute-api:eu-west-2:327778747031:aa826k16a9/*/*/*",
            "Condition": {
                "NotIpAddress": {
                    "aws:SourceIp": "194.101.83.23/32"
                }
            }
        }
    ]
}
EOF
}