// prevent destroy default true
variable "prevent_destroy" {
  type = bool
  default = true
}
// project specific identifiers
variable "asset_id" {
  type = string
}

variable "asset_name" {
  type = string
}
// environment etc.
variable "asset_group" {
  type = string
}

variable "_tofupi" {
  description = "Tofupi 内部变量"
  type = map(object({}))
  default = {
    aws_vpc_peering_connection = {
      nameKey = "id",
      # from tags
      projectID = "AssetID",
      exclude = [
        "arn",
        "id",
        "region",
        "accept_status",
        "owner_id",
        "status",
      ]
    },
  }
}

variable "short_name" {
  type = string
  default = null
}

variable "name" {
  type        = string
  description = "VPC Peering 连接名称（用于 tags）"

  validation {
    condition     = length(var.name) > 0
    error_message = "name 不能为空"
  }
}

variable "vpc_id" {
  type        = string
  description = "请求方 VPC ID"

  validation {
    condition     = can(regex("^vpc-[0-9a-f]+$", var.vpc_id))
    error_message = "vpc_id 必须是有效的 VPC ID，例如 vpc-123abc456"
  }
}

variable "peer_vpc_id" {
  type        = string
  description = "对端 VPC ID"

  validation {
    condition     = can(regex("^vpc-[0-9a-f]+$", var.peer_vpc_id))
    error_message = "peer_vpc_id 必须是有效的 VPC ID，例如 vpc-123abc456"
  }
}

variable "peer_owner_id" {
  type        = string
  description = "对端 AWS 账号 ID（跨账号 peering 时必填）"
  default     = null

  validation {
    condition = (
      var.peer_owner_id == null ||
      can(regex("^[0-9]{12}$", var.peer_owner_id))
    )
    error_message = "peer_owner_id 必须是 12 位 AWS 账号 ID"
  }
}

variable "peer_region" {
  type        = string
  description = "对端 Region（跨 Region peering 时必填）"
  default     = null
}

variable "auto_accept" {
  type        = bool
  description = "是否自动接受 peering（仅同账号或有权限时生效）"
  default     = true
}

variable "requester" {
  type        = map(object({
    allow_remote_vpc_dns_resolution = optional(bool, true)
  }))
  description = "请求方是否允许解析对端 VPC 的 DNS"
  default     = {}
}

variable "accepter" {
  type        = map(object({
    allow_remote_vpc_dns_resolution = optional(bool, true)
  }))
  description = "对端是否允许解析请求方 VPC 的 DNS"
  default     = {}
}

variable "requester_cidr_block" {
  type        = string
  description = "请求方 VPC CIDR（用于自动创建路由，可为空）"
  default     = null

  validation {
    condition = (
      var.requester_cidr_block == null ||
      can(regex("^[0-9]{1,3}(\\.[0-9]{1,3}){3}\\/([0-9]|[1-2][0-9]|3[0-2])$", var.requester_cidr_block))
    )
    error_message = "requester_cidr_block 必须是合法 IPv4 CIDR"
  }
}

variable "peer_cidr_block" {
  type        = string
  description = "对端 VPC CIDR（用于自动创建路由，可为空）"
  default     = null

  validation {
    condition = (
      var.peer_cidr_block == null ||
      can(regex("^[0-9]{1,3}(\\.[0-9]{1,3}){3}\\/([0-9]|[1-2][0-9]|3[0-2])$", var.peer_cidr_block))
    )
    error_message = "peer_cidr_block 必须是合法 IPv4 CIDR"
  }
}

variable "requester_route_table_ids" {
  type        = list(string)
  description = "请求方 VPC 中需要添加到对端 CIDR 路由的 Route Table IDs"
  default     = []
}

variable "accepter_route_table_ids" {
  type        = list(string)
  description = "对端 VPC 中需要添加到请求方 CIDR 路由的 Route Table IDs"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "基础 tags，会自动合并 Name / Module / Direction 等"
  default     = {}
}
