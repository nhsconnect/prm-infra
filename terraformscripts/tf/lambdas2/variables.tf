variable "aws_region" {
    default = "eu-west-2"
}

variable "environment" {
    default = "dev"
}

variable "api_gateway_endpoint_name" {
    default="EhrExtractHandlerApi"
}

variable "ehr_extract_handler_name" {
    default = "EhrExtractHandler"
}