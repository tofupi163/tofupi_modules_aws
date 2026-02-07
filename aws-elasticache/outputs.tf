output "primary_endpoint" {
  value = var.mode == "replication_group" ? aws_elasticache_replication_group.rg[0].primary_endpoint_address : aws_elasticache_cluster.cluster[0].cache_nodes[0].address
}

output "reader_endpoint" {
  value = var.mode == "replication_group"  ? aws_elasticache_replication_group.rg[0].reader_endpoint_address : null
}
