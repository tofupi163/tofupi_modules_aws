variable "_tofupi" {
  description = "Tofupi 内部变量"
  type = map(object({}))
  default = {
    aws_security_group = {
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
    aws_security_group_rule = {
      nameKey = "id",
      link = "aws_security_group.sg_rules.security_group_id.id",
      # exclude = [
      #   "arn",
      #   "id",
      #   "region",
      #   "owner_id",
      # ]
    },
  }
}

variable "name" {
  type = string
  default = null
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

variable "description" {
  type        = string
  description = "描述"
  default     = null
}

variable "vpc_id" {
  type = string
  description = "The VPC ID where subnet will be created"
}

variable "ingress" {
  type = list(object({
    description = optional(string, "")
    protocol    = string
    from_port   = number
    to_port     = number
    security_group_rule_id = optional(string, null)
    source_security_group_id = optional(string, null)
    cidr_blocks = optional(list(string), ["0.0.0.0/0"])
  }))
  default = null

  validation {
    condition = alltrue([
      for r in var.ingress :
      contains(["tcp", "udp", "icmp", "-1"], r.protocol)
    ])
    error_message = "ingress.protocol 必须是 \"tcp\"、\"udp\"、\"icmp\" 或 \"-1\"."
  }

  validation {
    condition = alltrue([
      for r in var.ingress :
      r.from_port >= 0 && r.from_port <= 65535
    ])
    error_message = "ingress.from_port 必须在 0 到 65535 之间."
  }

  validation {
    condition = alltrue([
      for r in var.ingress :
      r.to_port >= 0 && r.to_port <= 65535
    ])
    error_message = "ingress.to_port 必须在 0 到 65535 之间."
  }

  validation {
    condition = alltrue([
      for r in var.ingress :
      r.to_port >= r.from_port
    ])
    error_message = "ingress.to_port 必须大于或等于 from_port."
  }
}


variable "egress" {
  type = list(object({
    description = optional(string, "")
    protocol    = string
    from_port   = number
    to_port     = number
    security_group_rule_id = optional(string, null)
    source_security_group_id = optional(string, null)
    cidr_blocks = optional(list(string), ["0.0.0.0/0"])
  }))
  default = null

  validation {
    condition = alltrue([
      for r in var.egress :
      contains(["tcp", "udp", "icmp", "-1"], r.protocol)
    ])
    error_message = "egress.protocol 必须是 \"tcp\"、\"udp\"、\"icmp\" 或 \"-1\"."
  }

  validation {
    condition = alltrue([
      for r in var.egress :
      r.from_port >= 0 && r.from_port <= 65535
    ])
    error_message = "egress.from_port 必须在 0 到 65535 之间."
  }

  validation {
    condition = alltrue([
      for r in var.egress :
      r.to_port >= 0 && r.to_port <= 65535
    ])
    error_message = "egress.to_port 必须在 0 到 65535 之间."
  }

  validation {
    condition = alltrue([
      for r in var.egress :
      r.to_port >= r.from_port
    ])
    error_message = "egress.to_port 必须大于或等于 from_port."
  }
}


variable "sg_rules" {
  type = list(object({
    type        = string
    description = optional(string, "")
    protocol    = string
    from_port   = number
    to_port     = number
    security_group_rule_id = optional(string, null)
    source_security_group_id = optional(string, null)
    cidr_blocks = optional(list(string), ["0.0.0.0/0"])
  }))
  default = null

  validation {
    condition = alltrue([
      for r in var.sg_rules :
      contains(["ingress", "egress"], r.type)
    ])
    error_message = "sg_rules.type 必须是 \"ingress\" 或 \"egress\"."
  }

  validation {
    condition = alltrue([
      for r in var.sg_rules :
      contains(["tcp", "udp", "icmp", "-1"], r.protocol)
    ])
    error_message = "sg_rules.protocol 必须是 \"tcp\"、\"udp\"、\"icmp\" 或 \"-1\"."
  }

  validation {
    condition = alltrue([
      for r in var.sg_rules :
      r.from_port >= 0 && r.from_port <= 65535
    ])
    error_message = "sg_rules.from_port 必须在 0 到 65535 之间."
  }

  validation {
    condition = alltrue([
      for r in var.sg_rules :
      r.to_port >= 0 && r.to_port <= 65535
    ])
    error_message = "sg_rules.to_port 必须在 0 到 65535 之间."
  }

  validation {
    condition = alltrue([
      for r in var.sg_rules :
      r.to_port >= r.from_port
    ])
    error_message = "sg_rules.to_port 必须大于或等于 from_port."
  }
}

# sample
# sg_ingress:
#   - protocol: "tcp"
#     from_port: 22
#     to_port:  22
#     description:  "SSH"
#   - protocol:  "tcp"
#     from_port:  80
#     to_port:  80
#     description: "HTTP"


