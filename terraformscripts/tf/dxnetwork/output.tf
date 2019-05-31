output "unique_id" {
  description = "A unique identifier to ensure output is always updated"
  value       = "${uuid()}"
}
