variable "asset_id" {
  type        = string
  description = "Asset ID"
}

variable "asset_name" {
  type        = string
  description = "Asset Name"
}
// environment etc.
variable "asset_group" {
  type = string
}

variable "_tofupi" {
  description = "Tofupi 内部变量"
  type = map(object({}))
  default = {
    aws_vpc = {
      nameKey = "id",
      # from tags
      projectID = "AssetID",
      exclude = [
        "arn",
        "id",
        "region",
        "owner_id",
        "default_network_acl_id",
        "default_route_table_id",
        "main_route_table_id",
        "dhcp_options_id",
        "default_security_group_id",
      ]
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
variable "cidr_block" {
  type = string
}

variable "enable_dns_hostnames" {
  type = bool
  default = false
}

variable "enable_dns_support" {
  type = bool
  default = true
}

variable "enable_network_address_usage_metrics" {
  type = bool
  default = false
}

variable "ipv6_netmask_length" {
  type = number
  default = 0
}

variable "assign_generated_ipv6_cidr_block" {
  type = bool
  default = false
}

variable "instance_tenancy" {
  type = string
  default = "default"
}

variable "dhcp_options" {
  type = object({
    domain_name          = optional(string, null)
    domain_name_servers  = optional(list(string), ["AmazonProvidedDNS"])
    ntp_servers          = optional(list(string), [])
    netbios_name_servers = optional(list(string), [])
    netbios_node_type    = optional(number, null)
  })
  default = {}
}
