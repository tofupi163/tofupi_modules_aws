// prevent destroy default true
variable "prevent_destroy" {
  type = bool
  default = true
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
variable "_tofupi" {
  description = "Tofupi 内部变量"
  type = map(object({}))
  default = {
    aws_ssm_parameter = {
      # nameKey = "name",
      projectID = "AssetID",
      exclude = [
        "arn",
        "id",
        "region",
        "owner",
        "version",
      ]
    },
  }
}
variable "short_name" {
  type = string
  default = ""
}

variable "name" {
  type = string
  default = null
}

variable "tags" {
  type = map(string)
  default = null
}

variable "value" {
  type = string
  default = null
}

variable "description" {
  type = string
  default = null
}

variable "type" {
  type = string
  default = "String"
}

variable "value_file" {
  type = string
  default = null
}

variable "key_id" {
  type = string
  default = "alias/aws/ssm"
  validation {
    condition     = var.type == "SecureString" ? var.key_id != null : true
    error_message = "当 type 为 SecureString 时，key_id 不能为空"
  }
}

variable "tier" {
  type = string
  default = "Standard"
  validation {
    condition     = contains(["Standard", "Advanced", "Intelligent-Tiering"], var.tier)
    error_message = "tier 必须是 Standard、Advanced 或 Intelligent-Tiering 之一"
  }
}

variable "data_type" {
  type = string
  default = "text"
  validation {
    condition     = contains(["text", "aws:ec2:image", "aws:ec2:instance", "aws:ec2:key-pair", "aws:ec2:security-group", "aws:ec2:subnet", "aws:ec2:vpc", "aws:ssm:integration"], var.data_type)
    error_message = "data_type 必须是 text、aws:ec2:image、aws:ec2:instance、aws:ec2:key-pair、aws:ec2:security-group、aws:ec2:subnet、aws:ec2:vpc 或 aws:ssm:integration 之一"
  }
}
