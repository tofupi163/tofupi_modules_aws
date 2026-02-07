variable "asset_id" {
  type        = string
  description = "Asset ID"
}
variable "_tofupi" {
  description = "Tofupi 内部变量"
  type = map(object({}))
  default = {
    aws_subnet = {
      nameKey = "id",
      # from tags
      projectID = "AssetID",
      exclude = [
        "arn",
        "id",
        "region",
        "owner_id",
        "availability_zone_id",
        "availability_zone",
      ]
    },
  }
}

variable "asset_name" {
  type        = string
  description = "Asset Name"
}
// environment etc.
variable "asset_group" {
  type = string
}
variable "name" {
  type = string
  default = null
}
variable "tags" {
  type = map(string)
  default = null
}
variable "vpc_id" {
  type = string
  description = "The VPC ID where subnet will be created"
}
variable "cidr_block" {
  type = string
}

variable "ipv6_native" {
  type = bool
  default = false
}

variable "map_customer_owned_ip_on_launch" {
  type = bool
  default = false
}

variable "enable_lni_at_device_index" {
  type = number
  default = 0
}

variable "enable_resource_name_dns_aaaa_record_on_launch" {
  type = bool
  default = false
}

variable "enable_dns64" {
  type = bool
  default = false
}

variable "map_public_ip_on_launch" {
  type = bool
  default = false
}

variable "enable_resource_name_dns_a_record_on_launch" {
  type = bool
  default = false
}

variable "assign_ipv6_address_on_creation" {
  type = bool
  default = false
}

variable "private_dns_hostname_type_on_launch" {
  type = string
  default = "ip-name"
  validation {
    condition     = contains(["ip-name", "resource-name"], var.private_dns_hostname_type_on_launch)
    error_message = "private_dns_hostname_type_on_launch must be either 'ip-name' or 'resource-name'."
  }
}

