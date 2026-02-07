output "vpc_peering_connection_id" {
  value = aws_vpc_peering_connection.this.id
}

output "vpc_peering_status" {
  value = aws_vpc_peering_connection.this.status
}

output "requester_route_ids" {
  value = [for r in aws_route.requester_to_peer : r.id]
}

output "accepter_route_ids" {
  value = [for r in aws_route.peer_to_requester : r.id]
}
