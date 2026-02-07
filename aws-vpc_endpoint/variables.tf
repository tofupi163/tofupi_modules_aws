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
    aws_vpc_endpoint = {
      nameKey = "id",
      policy = "policy",
      # from tags
      projectID = "AssetID",
      exclude = [
        "arn",
        "id",
        "region",
        "owner_id",
        "state",
        "service_region",
        "requester_managed",
        "network_interface_ids",
        "dns_entry",
        "prefix_list_id",
      ]
    },
  }
}

variable "short_name" {
  type = string
  default = null
}

variable "name" {
  type = string
  default = null
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"

  validation {
    condition     = can(regex("^vpc-[0-9a-f]+$", var.vpc_id))
    error_message = "vpc_id 必须是有效的 VPC ID，例如 vpc-123abc456"
  }
}

variable "service_name" {
  type        = string
  description = "VPC Endpoint 服务名称，例如 com.amazonaws.us-east-1.s3"

  validation {
    condition     = length(var.service_name) > 0
    error_message = "service_name 不能为空"
  }
}

variable "vpc_endpoint_type" {
  type        = string
  description = "Endpoint 类型：Interface 或 Gateway"
  default     = "Interface"

  validation {
    condition     = contains(["Interface", "Gateway"], var.vpc_endpoint_type)
    error_message = "vpc_endpoint_type 必须是 Interface 或 Gateway"
  }
}

variable "subnet_ids" {
  type        = list(string)
  description = "Interface Endpoint 需要的子网列表"
  default     = []

  validation {
    condition = (
      var.vpc_endpoint_type == "Gateway" ||
      (var.vpc_endpoint_type == "Interface" && length(var.subnet_ids) > 0)
    )
    error_message = "Interface 类型必须提供 subnet_ids"
  }
}

variable "subnet_configuration" {
  type        = list(object({
    subnet_id           = string
    ip_address_type     = string
  }))
  description = "Interface Endpoint 子网配置"
  default     = []

  validation {
    condition = (
      var.vpc_endpoint_type == "Gateway" ||
      (var.vpc_endpoint_type == "Interface" && length(var.subnet_configuration) > 0)
    )
    error_message = "Interface 类型必须提供 subnet_configuration"
  }
}

variable "security_group_ids" {
  type        = list(string)
  description = "Interface Endpoint 的安全组"
  default     = []

  validation {
    condition = (
      var.vpc_endpoint_type == "Gateway" ||
      (var.vpc_endpoint_type == "Interface" && length(var.security_group_ids) > 0)
    )
    error_message = "Interface 类型必须提供 security_group_ids"
  }
}

variable "route_table_ids" {
  type        = list(string)
  description = "Gateway Endpoint 的路由表 ID 列表"
  default     = []

  validation {
    condition = (
      var.vpc_endpoint_type == "Interface" ||
      (var.vpc_endpoint_type == "Gateway" && length(var.route_table_ids) > 0)
    )
    error_message = "Gateway 类型必须提供 route_table_ids"
  }
}

variable "ip_address_type" {
  type        = string
  description = "IP 地址类型（仅 Interface 支持），可选值：ipv4、ipv6 或 dualstack"
  default     = "ipv4"

  validation {
    condition = (
      var.vpc_endpoint_type == "Gateway" ||
      (var.vpc_endpoint_type == "Interface" && contains(["ipv4", "ipv6", "dualstack"], var.ip_address_type))
    )
    error_message = "ip_address_type 仅适用于 Interface 类型，且必须是 ipv4、ipv6 或 dualstack"
  }
}

variable "private_dns_enabled" {
  type        = bool
  description = "是否启用 Private DNS（仅 Interface 支持）"
  default     = true

  validation {
    condition = (
      var.vpc_endpoint_type == "Gateway" ||
      (var.vpc_endpoint_type == "Interface" && var.private_dns_enabled == true)
      || (var.vpc_endpoint_type == "Interface" && var.private_dns_enabled == false)
    )
    error_message = "private_dns_enabled 仅适用于 Interface 类型"
  }
}

variable "dns_options" {
  type        = object({
    dns_record_ip_type                             = optional(string, "ipv4")
    private_dns_only_for_inbound_resolver_endpoint = optional(bool, false)
  })
  description = "DNS 选项"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "标签"
  default     = {}
}

variable "policy" {
  type        = string
  description = "VPC Endpoint Policy（JSON 字符串，可选）"
  default     = null
}

variable "policy_file" {
  type        = string
  description = "VPC Endpoint Policy（JSON 字符串，可选）"
  default     = null
}

variable "enable_minimal_policy" {
  type        = bool
  description = "是否自动生成最小权限 VPC Endpoint Policy"
  default     = false
}

variable "allowed_principal_arns" {
  type        = list(string)
  description = "允许访问 VPC Endpoint 的 IAM ARN 列表"
  default     = []

  validation {
    condition = alltrue([
      for arn in var.allowed_principal_arns :
      can(regex("^arn:aws:iam::[0-9]{12}:.+$", arn))
    ])
    error_message = "allowed_principal_arns 必须是有效的 IAM ARN"
  }
}

variable "allowed_service_principals" {
  type        = list(string)
  description = "允许访问 Endpoint 的 AWS 服务，例如 ec2.amazonaws.com"
  default     = []

  validation {
    condition = alltrue([
      for s in var.allowed_service_principals :
      can(regex("^[a-z0-9.-]+\\.amazonaws\\.com$", s))
    ])
    error_message = "allowed_service_principals 必须是有效的 AWS 服务域名，例如 ec2.amazonaws.com"
  }
}

variable "create_security_group" {
  type        = bool
  description = "是否为 Interface Endpoint 自动创建 Security Group"
  default     = false
}

variable "security_group_ids" {
  type        = list(string)
  description = "Interface Endpoint 使用的 Security Group ID 列表（当 create_security_group = false 时必填）"
  default     = []

  validation {
    condition = (
      var.vpc_endpoint_type == "Gateway" ||
      var.create_security_group ||
      (var.vpc_endpoint_type == "Interface" && length(var.security_group_ids) > 0)
    )
    error_message = "Interface 类型且未自动创建 SG 时，必须提供 security_group_ids"
  }
}

variable "cidr_blocks" {
  type        = list(string)
  description = "Gateway Endpoint 的 CIDR 块列表（仅 Gateway 支持）"
  default     = []

  validation {
    condition = (
      var.vpc_endpoint_type == "Gateway" && length(var.cidr_blocks) > 0
    )
    error_message = "Gateway 类型必须提供 cidr_blocks"
  }
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "自动创建的 SG 允许访问的 CIDR 列表"
  default     = ["10.0.0.0/8"]
}

variable "security_group" {
  type = object({
    ingress = optional(list(object({
      from_port        = number
      to_port          = number
      protocol         = string
      cidr_blocks      = optional(list(string), [])
      ipv6_cidr_blocks = optional(list(string), [])
      security_groups  = optional(list(string), [])
      description      = optional(string, null)
    })), [])

    egress = optional(list(object({
      from_port        = number
      to_port          = number
      protocol         = string
      cidr_blocks      = optional(list(string), [])
      ipv6_cidr_blocks = optional(list(string), [])
      security_groups  = optional(list(string), [])
      description      = optional(string, null)
    })), [])
  })

  description = "Interface Endpoint 自动创建的 Security Group 配置"
  default = {
    ingress = []
    egress  = []
  }

  validation {
    condition = alltrue([
      for rule in var.security_group.ingress :
      rule.from_port >= -1 &&
      rule.to_port   >= -1 &&
      length(rule.protocol) > 0
    ])
    error_message = "security_group.ingress 中的 from_port/to_port 必须 >= -1，protocol 不能为空"
  }

  validation {
    condition = alltrue([
      for rule in var.security_group.egress :
      rule.from_port >= -1 &&
      rule.to_port   >= -1 &&
      length(rule.protocol) > 0
    ])
    error_message = "security_group.egress 中的 from_port/to_port 必须 >= -1，protocol 不能为空"
  }
}
