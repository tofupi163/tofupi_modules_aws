variable "name" {
  type = string
  default = null
}

variable "_tofupi" {
  description = "Tofupi 内部变量"
  type = map(object({}))
  default = {
    aws_route_table = {
      nameKey = "id",
      # from tags
      projectID = "AssetID",
      exclude = [
        "arn",
        "id",
        "region",
        "create_time",
        "availability_zone",
        "owner_id",
      ]
    },
    aws_route_table_association = {
      nameKey = "id",
      # from tags
      link = "aws_route_table.table_association.route_table_id.id",
    },
    aws_main_route_table_association = {
      nameKey = "id",
      # from tags
      link = "aws_route_table.main_table_association.route_table_id.id",
    },
  }
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


variable "tags" {
  type = map(string)
  default = null
}
variable "vpc_id" {
  type = string
  description = "The VPC ID"
}

variable "routes" {
  type = list(object({
    cidr_block     = optional(string)
    ipv6_cidr_block = optional(string)
    gateway_id     = optional(string)
    nat_gateway_id = optional(string)
    transit_gateway_id = optional(string)
    vpc_peering_connection_id = optional(string)
    destination_prefix_list_id = optional(string)
    transit_gateway_id         = optional(string)
  }))
  default = []
}
# sample
# routes:
#   - cidr_block: "0.0.0.0/0"
#     gateway_id: "igw-123456"
#   - cidr_block: "10.0.2.0/24"
#     gateway_id: "nat-abc123"

variable "propagating_vgws" {
  type = list(string)
  default = []
}

variable "subnet_id" {
  type = string
  default = null
}

variable "table_association" {
  type = list(object({
    subnet_id = string
    gateway_id = optional(string, null)
  }))
  default = null
}

variable "main_table_association" {
  type = list(object({
    vpc_id = string
  }))
  default = null
}


