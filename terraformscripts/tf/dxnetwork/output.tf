output "unique_id" {
  description = "A unique identifier to ensure output is always updated"
  value       = "${uuid()}"
}

output "jump_ip_address" {
  description = "The IP address of the jump box"
  value       = "${aws_instance.jump.*.public_ip}"
}
