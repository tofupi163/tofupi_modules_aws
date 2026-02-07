variable "name" {
  type = string
  default = null
}

variable "_tofupi" {
  description = "Tofupi 内部变量"
  type = map(object({}))
  default = {
    aws_internet_gateway = {
      nameKey = "tags.Name",
      # from tags
      projectID = "AssetID",
      exclude = [
        "arn",
        "id",
        "region",
        "owner_id",
      ]
    }
  }
}

variable "tags" {
  type = map(string)
  default = null
}
variable "vpc_id" {
  type = string
  description = "The VPC ID where subnet will be created"
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
