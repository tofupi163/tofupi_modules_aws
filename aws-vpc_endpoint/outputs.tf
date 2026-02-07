output "vpc_endpoint_id" {
  value = aws_vpc_endpoint.this.id
}

output "vpc_endpoint_arn" {
  value = aws_vpc_endpoint.this.arn
}

output "dns_entries" {
  value = aws_vpc_endpoint.this.dns_entry
}
