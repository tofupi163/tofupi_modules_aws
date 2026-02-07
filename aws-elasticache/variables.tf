// prevent destroy default true
variable "prevent_destroy" {
  type = bool
  default = true
}

variable "_tofupi" {
  description = "Tofupi 内部变量"
  type = map(object({}))
  default = {
    aws_elasticache_cluster = {
      nameKey = "id",
      # from tags
      projectID = "AssetID",
      exclude = [
        "arn",
        "id",
        "region",
        "engine_version_actual",
        "availability_zone",
      ]
    },
    aws_elasticache_subnet_group = {
      link = "aws_elasticache_cluster.subnet_group_name"
    },
    aws_elasticache_parameter_group = {
      link = "aws_elasticache_cluster.parameter_group_name"
    }
  }
}

variable "name" {
  type = string
}

variable "tags" {
  type = map(string)
  default = null
}


variable "asset_id" {
  type = string
  description = "当前资源所属资产ID"
}
variable "asset_name" {
  type        = string
  description = "Asset Name"
}

variable "asset_group" {
  type = string
  description = "当前资源所属资产分组"
}

variable "network_type" {
  type        = string
  description = "网络类型，例如 ipv4"
  default     = "ipv4"
  validation {
    condition     = contains(["ipv4","ipv6","dual_stack"], var.network_type)
    error_message = "network_type 目前仅支持 ipv4, ipv6, dual_stack"
  }
}

variable "ip_discovery" {
  type        = string
  description = "IP 发现方式，例如 ipv4"
  default     = "ipv4"
  validation {
    condition     = contains(["ipv4","ipv6"], var.ip_discovery)
    error_message = "ip_discovery 目前仅支持 ipv4, ipv6"
  }
}

variable "snapshot_window" {
  type = string
  description = "每日备份时间窗口，格式为 hh24:mi-hh24:mi，例如 05:00-09:00"
  default = "05:00-09:00"
}

variable "maintenance_window" {
  type = string
  description = "每周维护时间窗口，格式为 ddd:hh24:mi-ddd:hh24:mi，例如 sun:05:00-sun:09:00"
  default = ""
}

variable "snapshot_retention_limit" {
  type = number
  description = "快照保留天数，0 表示不保留"
  default = 0
}

variable "mode" {
  type        = string
  description = "cluster 或 replication_group"
  validation {
    condition     = contains(["cluster", "replication_group"], var.mode)
    error_message = "mode 必须是 cluster 或 replication_group"
  }
}

variable "az_mode" {
  type        = string
  default     = "single-az"

  validation {
    condition = (
      (var.mode == "cluster"            && var.az_mode == "single-az") ||
      (var.mode == "replication_group"  && contains(["single-az", "cross-az"], var.az_mode))
    )
    error_message = "当 mode=cluster 时，az_mode 只能为 single-az；cross-az 仅支持 replication_group"
  }
}

variable "cluster_id" {
  type        = string
  description = "Cluster 或 Replication Group ID"
}

variable "engine" {
  type        = string
  description = "redis 或 memcached"
  validation {
    condition     = contains(["redis", "memcached"], var.engine)
    error_message = "engine 必须是 redis 或 memcached"
  }
}

variable "engine_version" {
  type        = string
  description = "Engine version，例如 redis 7.0 或 memcached 1.6.17"
}

variable "auto_minor_version_upgrade" {
  type        = bool
  default     = true
  description = "是否自动升级小版本"
}

variable "at_rest_encryption_enabled" {
  type        = bool
  description = "是否启用静态加密（仅 Redis 支持）"
  default     = true

  validation {
    condition = (
      var.mode == "replication_group" ||
      (var.mode == "cluster" && var.at_rest_encryption_enabled == false)
    )
    error_message = "at_rest_encryption_enabled 仅在 replication_group 模式下可启用"
  }
}

variable "automatic_failover_enabled" {
  type        = bool
  description = "是否启用自动故障切换（仅 replication_group 支持）"
  default     = true

  validation {
    condition = (
      var.mode == "replication_group" ||
      (var.mode == "cluster" && var.automatic_failover_enabled == false)
    )
    error_message = "automatic_failover_enabled 仅在 replication_group 模式下可启用"
  }
}

variable "data_tiering_enabled" {
  type        = bool
  description = "是否启用数据分层（仅 Redis 6+、特定节点类型支持）"
  default     = false

  validation {
    condition = (
      var.mode == "replication_group" ||
      (var.mode == "cluster" && var.data_tiering_enabled == false)
    )
    error_message = "data_tiering_enabled 仅在 replication_group 模式下可启用"
  }
}

variable "cluster_mode" {
  type        = bool
  description = "是否启用 Redis Cluster Mode（分片模式）"
  default     = false

  validation {
    condition = (
      var.mode == "replication_group" ||
      (var.mode == "cluster" && var.cluster_mode == false)
    )
    error_message = "cluster_mode 仅在 replication_group 模式下可启用"
  }
}
variable "transit_encryption_enabled" {
  type        = bool
  description = "是否启用传输加密（TLS）"
  default     = true

  validation {
    condition = (
      var.mode == "replication_group" ||
      (var.mode == "cluster" && var.transit_encryption_enabled == false)
    )
    error_message = "transit_encryption_enabled 仅在 replication_group 模式下可启用"
  }
}

variable "transit_encryption_mode" {
  type        = string
  description = "TLS 模式：preferred 或 required"
  default     = "required"

  validation {
    condition = contains(["preferred", "required"], var.transit_encryption_mode)
    error_message = "transit_encryption_mode 必须是 preferred 或 required"
  }
}

variable "user_group_ids" {
  type        = list(string)
  description = "Redis ACL 用户组 ID 列表（仅 Redis 6+ 的 replication_group 支持）"
  default     = []

  validation {
    condition = (
      # 允许 replication_group + redis + version >= 6
      (
        var.mode == "replication_group" &&
        var.engine == "redis" &&
        tonumber(regex("^([0-9]+)", var.engine_version)) >= 6
      )
      ||
      # 其他情况必须为空
      (
        length(var.user_group_ids) == 0
      )
    )

    error_message = "user_group_ids 仅在 mode=replication_group 且 engine=redis 且 engine_version>=6 时可用；其他情况下必须为空"
  }
}

variable "node_type" {
  type        = string
  description = "cache.t3.micro 等"
}

variable "num_cache_nodes" {
  type        = number
  description = "cluster 模式下的节点数"
  default     = 1

  validation {
    condition = (
      (var.mode == "cluster" && var.engine == "redis"     && var.num_cache_nodes == 1) ||
      (var.mode == "cluster" && var.engine == "memcached" && var.num_cache_nodes >= 1 && var.num_cache_nodes <= 20) ||
      (var.mode == "replication_group")
    )
    error_message = "cluster 模式下 redis 只能 1 节点；memcached 1~20；replication_group 不使用此字段"
  }
}

variable "replicas" {
  type        = number
  description = "replication_group 模式下的副本数量"
  default     = 0

  validation {
    condition = (
      (var.mode == "replication_group" && var.replicas >= 0 && var.replicas <= 5) ||
      (var.mode == "cluster")
    )
    error_message = "replication_group 模式下 replicas 必须在 0~5 之间"
  }
}

variable "port" {
  type        = number
  description = "监听端口，0 表示使用默认端口"
  default     = 0

  validation {
    condition     = var.port == 0 || (var.port > 0 && var.port < 65536)
    error_message = "port 必须是有效 TCP 端口号或 0"
  }
}



variable "subnet_group_name" {
  type = map(object({
    subnet_ids = list(string)
  }))
  validation {
    condition     = length(var.subnet_group_name.subnet_ids) >= 2
    error_message = "DocumentDB 要求至少两个 subnet（跨 AZ）."
  }
}

variable "security_group_ids" {
  type = list(string)
  validation {
    condition     = length(var.security_group_ids) >= 1
    error_message = "至少需要一个 security group"
  }
}

variable "parameter_group_name" {
  type = string
  default = ""
}

variable "parameter_group_names" {
  type = map(object({
    name        = string
    family      = string
    description = optional(string, "parameter group")
    parameters = optional(map(object({
      value        = string
      apply_method = optional(string, "pending-reboot")
    })), {})
  }))

  default = null

  # family 校验（根据 AWS 官方）
  validation {
    condition = var.parameter_group_name == null ? true : contains(
      ["docdb3.6", "docdb4.0", "docdb5.0"],
      var.parameter_group_name.family
    )
    error_message = "family 必须是 docdb3.6、docdb4.0 或 docdb5.0."
  }

  validation {
    condition = alltrue([
      for p in var.parameter_group_name.parameters :
      contains(["immediate", "pending-reboot"], p.apply_method)
    ])
    error_message = "apply_method 必须是 immediate 或 pending-reboot."
  }
}

