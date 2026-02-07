variable "name" {
  type = string
  default = null
}


variable "_tofupi" {
  description = "Tofupi 内部变量"
  type = map(object({}))
  default = {
    aws_network_acl = {
      # from tags
      nameKey = "id",
      projectID = "AssetID",
      exclude = [
        "arn",
        "id",
        "region",
        "owner_id",
      ]
    },
    aws_default_network_acl = {
      # from alb_listeners
      nameKey = "id",
      projectID = "AssetID",
      exclude = [
        "arn",
        "id",
        "owner_id",
        "region",
      ]
    },
  }
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

variable "vpc_id" {
  type = string
  description = "The VPC ID where subnet will be created"
}

variable "nacl_ingress" {
  type = list(object({
    rule_no     = number
    protocol    = string
    action      = string
    cidr_block  = optional(string, "0.0.0.0/0")
    from_port   = number
    to_port     = number
    description = optional(string, "")
  }))

  default = []

  validation {
    condition = alltrue([
      for r in var.nacl_ingress :
      contains(["allow", "deny"], r.action)
    ])
    error_message = "nacl_ingress.action 必须是 \"allow\" 或 \"deny\"."
  }

  validation {
    condition = alltrue([
      for r in var.nacl_ingress :
      r.rule_no >= 1 && r.rule_no <= 32766
    ])
    error_message = "nacl_ingress.rule_no 必须在 1 到 32766 之间（AWS 要求）."
  }

  validation {
    condition = alltrue([
      for r in var.nacl_ingress :
      contains(["tcp", "udp", "icmp", "-1"], r.protocol)
    ])
    error_message = "nacl_ingress.protocol 必须是 \"tcp\"、\"udp\"、\"icmp\" 或 \"-1\"（表示所有协议）."
  }

  validation {
    condition = alltrue([
      for r in var.nacl_ingress :
      r.from_port >= 0 && r.from_port <= 65535
    ])
    error_message = "nacl_ingress.from_port 必须在 0 到 65535 之间."
  }

  validation {
    condition = alltrue([
      for r in var.nacl_ingress :
      r.to_port >= 0 && r.to_port <= 65535
    ])
    error_message = "nacl_ingress.to_port 必须在 0 到 65535 之间."
  }

  validation {
    condition = alltrue([
      for r in var.nacl_ingress :
      r.to_port >= r.from_port
    ])
    error_message = "nacl_ingress.to_port 必须大于或等于 from_port."
  }
}
# sample
# nacl_ingress :
#   - rule_no:100
#     protocol: "tcp"
#     action:"allow"
#     from_port:22
#     to_port:22
#     description:"Allow SSH"
#   - rule_no:120
#     protocol: "tcp"
#     action:"allow"
#     from_port:80
#     to_port:80
#     description:"Allow WEB"

variable "nacl_egress" {
  type    = list(object({
    rule_no    = number
    protocol   = string
    action     = string
    cidr_block = optional(string, "0.0.0.0/0")
    from_port  = number
    to_port    = number
    description = optional(string, "")
  }))
  default = []

  validation {
    condition = alltrue([
      for r in var.nacl_egress :
      contains(["allow", "deny"], r.action)
    ])
    error_message = "nacl_egress.action 必须是 \"allow\" 或 \"deny\"."
  }

  validation {
    condition = alltrue([
      for r in var.nacl_egress :
      r.rule_no >= 1 && r.rule_no <= 32766
    ])
    error_message = "nacl_egress.rule_no 必须在 1 到 32766 之间（AWS 要求）."
  }

  validation {
    condition = alltrue([
      for r in var.nacl_egress :
      contains(["tcp", "udp", "icmp", "-1"], r.protocol)
    ])
    error_message = "nacl_egress.protocol 必须是 \"tcp\"、\"udp\"、\"icmp\" 或 \"-1\"（表示所有协议）."
  }

  validation {
    condition = alltrue([
      for r in var.nacl_egress :
      r.from_port >= 0 && r.from_port <= 65535
    ])
    error_message = "nacl_egress.from_port 必须在 0 到 65535 之间."
  }

  validation {
    condition = alltrue([
      for r in var.nacl_egress :
      r.to_port >= 0 && r.to_port <= 65535
    ])
    error_message = "nacl_egress.to_port 必须在 0 到 65535 之间."
  }

  validation {
    condition = alltrue([
      for r in var.nacl_egress :
      r.to_port >= r.from_port
    ])
    error_message = "nacl_egress.to_port 必须大于或等于 from_port."
  }
}


variable "subnet_ids" {
  type = list(string)
  description = "A list of subnet IDs to associate with the Network ACL."
  default = []
}
