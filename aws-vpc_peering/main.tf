data "aws_caller_identity" "current" {}

locals {
  base_tags = merge(
    var.tags,
    {
      Name   = var.name
      Module = "vpc-peering-connection"
    }
  )
}

resource "aws_vpc_peering_connection" "this" {
  vpc_id        = var.vpc_id
  peer_vpc_id   = var.peer_vpc_id
  peer_owner_id = var.peer_owner_id
  peer_region   = var.peer_region

  auto_accept = var.auto_accept

  dynamic "requester" {
    // only add if map is not empty
    for_each = length(var.requester) > 0 ? [var.requester] : null
    content {
      allow_remote_vpc_dns_resolution = var.requester.allow_remote_vpc_dns_resolution 
    }
  }

  dynamic "accepter" {
    for_each = length(var.accepter) > 0 ? [var.accepter] : null
    content {
      allow_remote_vpc_dns_resolution = var.accepter.allow_remote_vpc_dns_resolution 
    }
  }

  tags = local.base_tags
}

# 请求方 → 对端 路由
resource "aws_route" "requester_to_peer" {
  count = length(var.requester_route_table_ids) > 0 && var.peer_cidr_block != null ? length(var.requester_route_table_ids) : 0

  route_table_id            = var.requester_route_table_ids[count.index]
  destination_cidr_block    = var.peer_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id

}

# 对端 → 请求方 路由
resource "aws_route" "peer_to_requester" {
  count = length(var.accepter_route_table_ids) > 0 && var.requester_cidr_block != null ? length(var.accepter_route_table_ids) : 0

  route_table_id            = var.accepter_route_table_ids[count.index]
  destination_cidr_block    = var.requester_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}
