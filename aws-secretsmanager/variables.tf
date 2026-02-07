// prevent destroy default true
variable "prevent_destroy" {
  type = bool
  default = true
}

variable "_tofupi" {
  description = "Tofupi 内部变量"
  type = map(object({}))
  default = {
    aws_secretsmanager_secret = {
      # from tags
      # nameKey = "bucket",
      projectID = "AssetID",
      exclude = [
        "arn",
        "id",
        "region",
      ]
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


variable "short_name" {
  type = string
  default = null
}

variable "tags" {
  type = map(string)
  default = null
}

variable "name" {
  type        = string
  description = "Secret 名称"
}

variable "description" {
  type        = string
  description = "Secret 描述"
  default     = null
}

variable "create_kms_key" {
  type        = bool
  description = "是否自动创建 KMS Key"
  default     = false
}

variable "kms_key_id" {
  type        = string
  description = "自定义 KMS Key（create_kms_key = false 时必填）"
  default     = null

  validation {
    condition = (
      var.create_kms_key == true ||
      (var.create_kms_key == false && var.kms_key_id != null)
    )
    error_message = "create_kms_key = false 时必须提供 kms_key_id"
  }
}

variable "create_random_password" {
  type        = bool
  description = "是否自动生成随机密码"
  default     = false
}

variable "random_password_length" {
  type        = number
  description = "随机密码长度"
  default     = 32

  validation {
    condition     = var.random_password_length >= 16
    error_message = "random_password_length 必须 >= 16"
  }
}

variable "secret_data" {
  type        = map(any)
  description = "写入 Secret 的 JSON 数据（如果 create_random_password=true，则 password 字段会被覆盖）"
  default     = {}
}


# module "db_secret" {
#   source = "./modules/secretsmanager_secret"
#   name = "${local.base_name}-db-secret"
#   create_kms_key           = true
#   create_random_password   = true
#   random_password_length   = 32
#   secret_data = {
#     username = var.master_username
#     engine   = var.engine
#     host     = "placeholder" # 可以在 RDS 创建后再更新
#     port     = var.port
#   }
#   tags = local.merged_tags
# }
