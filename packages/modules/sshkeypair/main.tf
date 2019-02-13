resource "tls_private_key" "generated" {
  algorithm = "RSA"
}

resource "aws_key_pair" "generated" {
  key_name   = "${var.name}"
  public_key = "${tls_private_key.generated.public_key_openssh}"
}

resource "aws_s3_bucket_object" "saved" {
    bucket = "${var.bucket}"
    key = "${var.name}"
    content = "${tls_private_key.generated.private_key_pem}"
    content_type = "text/plain"
    server_side_encryption = "aws:kms"
}