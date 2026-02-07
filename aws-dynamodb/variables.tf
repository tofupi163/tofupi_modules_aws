variable "tags" {
  type = map(string)
  default = null
}

variable "name" {
  type        = string
  description = "DynamoDB table name"

  validation {
    condition     = length(var.name) > 0
    error_message = "name 不能为空."
  }
}

variable "_tofupi" {
  description = "Tofupi 内部变量"
  type = map(object({}))
  default = {
    aws_dynamodb_table = {
      projectID = "AssetID",
      exclude = [
        "arn",
        "id",
        "region",
      ]
    }
  }
}

variable "deletion_protection_enabled" {
  type = bool
  default = false
}

variable "billing_mode" {
  type        = string
  default     = "PAY_PER_REQUEST"
  description = "PAY_PER_REQUEST 或 PROVISIONED"

  validation {
    condition     = contains(["PAY_PER_REQUEST", "PROVISIONED"], var.billing_mode)
    error_message = "billing_mode 必须是 PAY_PER_REQUEST 或 PROVISIONED."
  }
}

variable "table_class" {
  type        = string
  default     = "STANDARD"
  description = "DynamoDB table class"

  validation {
    condition     = contains(["STANDARD", "STANDARD_INFREQUENT_ACCESS"], var.table_class)
    error_message = "table_class 必须是 STANDARD 或 STANDARD_INFREQUENT_ACCESS."
  }
}

variable "point_in_time_recovery" {
  type = object({
    enabled = bool
    recovery_period_in_days = number
  })
  default = {
    enabled = false
    recovery_period_in_days = 35
  }
}

variable "hash_key" {
  type        = string
  description = "Primary hash key"
}

variable "range_key" {
  type        = string
  default     = null
}

variable "attributes" {
  type = list(object({
    name = string
    type = string # S | N | B
  }))

  validation {
    condition = alltrue([
      for a in var.attributes :
      contains(["S", "N", "B"], a.type)
    ])
    error_message = "attributes[*].type 必须是 S、N 或 B."
  }
}

variable "read_capacity" {
  type    = number
  default = null
  # 校验：PROVISIONED 必须提供容量
  validation {
    condition = (
      var.billing_mode == "PAY_PER_REQUEST"
      || var.read_capacity != null
    )
    error_message = "PROVISIONED 模式下必须提供 read_capacity 和 write_capacity."
  }
}

variable "write_capacity" {
  type    = number
  default = null

  # 校验：PROVISIONED 必须提供容量
  validation {
    condition = (
      var.billing_mode == "PAY_PER_REQUEST"
      || var.write_capacity != null
    )
    error_message = "PROVISIONED 模式下必须提供 read_capacity 和 write_capacity."
  }
}

variable "global_secondary_index" {
  type = list(object({
    name            = string
    hash_key        = string
    range_key       = optional(string, null)
    projection_type = string
    read_capacity   = optional(number, null)
    write_capacity  = optional(number, null)
  }))
  default = []

  validation {
    condition = alltrue([
      for g in var.global_secondary_index :
      contains(["ALL", "KEYS_ONLY", "INCLUDE"], g.projection_type)
    ])
    error_message = "GSI projection_type 必须是 ALL、KEYS_ONLY 或 INCLUDE."
  }
}

variable "local_secondary_index" {
  type = list(object({
    name            = string
    range_key       = string
    projection_type = string
  }))
  default = []

  validation {
    condition = alltrue([
      for l in var.local_secondary_index :
      contains(["ALL", "KEYS_ONLY", "INCLUDE"], l.projection_type)
    ])
    error_message = "LSI projection_type 必须是 ALL、KEYS_ONLY 或 INCLUDE."
  }
}

variable "ttl" {
  type = object({
    attribute_name = string
    enabled        = bool
  })
  default = null
}

variable "stream_enabled" {
  type    = bool
  default = false
}

variable "stream_view_type" {
  type    = string
  default = null

  validation {
    condition = (
      var.stream_enabled == false
      || contains(["NEW_IMAGE", "OLD_IMAGE", "NEW_AND_OLD_IMAGES", "KEYS_ONLY"], var.stream_view_type)
    )
    error_message = "stream_view_type 必须是 NEW_IMAGE、OLD_IMAGE、NEW_AND_OLD_IMAGES 或 KEYS_ONLY."
  }
}

variable "server_side_encryption" {
  type = list(object({
    enabled     = bool
    kms_key_arn = optional(string, null)
  }))
  default = []

  validation {
    condition = (
      var.server_side_encryption.enabled == false
      || var.server_side_encryption.kms_key_arn == null
      || can(regex("^arn:aws:kms:", var.server_side_encryption.kms_key_arn))
    )
    error_message = "server_side_encryption.kms_key_arn 必须是有效的 KMS ARN."
  }
}
