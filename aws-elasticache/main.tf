
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_cluster
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_replication_group


resource "aws_elasticache_cluster" "cluster" {
  count = var.mode == "cluster" ? 1 : 0

  cluster_id           = var.cluster_id
  engine               = var.engine
  engine_version       = var.engine_version
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes
  port                 = var.port == 0 ? (var.engine == "redis" ? 6379 : 11211) : var.port

  snapshot_window    = var.engine == "redis" ? var.snapshot_window : null
  # snapshot_retention_limit = var.engine == "redis" ? var.snapshot_retention_limit : null
  maintenance_window = var.maintenance_window != "" ? var.maintenance_window : null
  subnet_group_name    = aws_elasticache_subnet_group.this.name
  security_group_ids   = var.security_group_ids

  parameter_group_name = var.parameter_group_name != "" ? aws_elasticache_parameter_group.this[0].name : "default.${var.engine}${var.engine_version}"
  tags = var.tags
}

resource "aws_elasticache_replication_group" "rg" {
  count = var.mode == "replication_group" ? 1 : 0

  replication_group_id          = var.cluster_id
  description = "Redis replication group for ${var.cluster_id}"

  
  engine               = "redis"
  engine_version       = var.engine_version
  node_type            = var.node_type
  port                 = var.port == 0 ? 6379 : var.port

  subnet_group_name    = aws_elasticache_subnet_group.this.name
  security_group_ids   = var.security_group_ids

  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  automatic_failover_enabled = var.automatic_failover_enabled
  data_tiering_enabled       = var.data_tiering_enabled
  cluster_mode = var.cluster_mode ? "enabled" : "disabled"
  multi_az_enabled = var.az_mode == "cross-az"

  transit_encryption_enabled = var.transit_encryption_enabled
  transit_encryption_mode    = var.transit_encryption_mode
  user_group_ids             = var.user_group_ids
  num_cache_clusters = var.replicas + 1

  parameter_group_name = var.parameter_group_name != "" ? aws_elasticache_parameter_group.this[0].name : "default.redis${substr(var.engine_version, 0, 1)}"
  tags = {
    Cluster_id    = var.cluster_id
    Description = "Replication group for ${var.engine} ${var.cluster_id}"
    AssetID       = var.asset_id
  }
}


# -------------------------
resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.name}-subnet-group"
  subnet_ids = var.subnet_group_name.subnet_ids ? var.subnet_group_name.subnet_ids : []
  tags = merge(
    var.tags != null ? var.tags : {},
    {
      Name = "${var.name}-subnet-group"
    }
  )
}

# -------------------------
resource "aws_elasticache_parameter_group" "this" {
  count = var.parameter_group_name == null ? 0 : 1

  name        = var.parameter_group_name.name
  family      = var.parameter_group_name.family
  description = var.parameter_group_name.description != null ? var.parameter_group_name.description : "Managed by Terraform"
  dynamic "parameter" {
    for_each = var.parameter_group_name.parameters
    content {
      name         = parameter.key
      value        = parameter.value.value
    }
  }
  tags = merge(
    var.tags != null ? var.tags : {},
    {
      Name = "${var.name}-subnet-group"
    }
  )
}
