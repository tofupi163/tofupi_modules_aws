// prevent destroy default true
variable "prevent_destroy" {
  type = bool
  default = true
}

variable "_tofupi" {
  description = "Tofupi 内部变量"
  type = map(object({}))
  default = {
    aws_sqs_queue = {
      # nameKey = "name",
      policy = "policy",
      projectID = "AssetID",
      exclude = [
        "arn",
        "id",
        "region",
        "owner",
        "url",
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
variable "name" {
  type        = string
  description = "SQS 队列名称"

  validation {
    condition     = length(var.name) > 0
    error_message = "name 不能为空"
  }
}

variable "fifo_queue" {
  type        = bool
  description = "是否为 FIFO 队列"
  default     = false
}

variable "content_based_deduplication" {
  type        = bool
  description = "FIFO 队列是否启用内容去重"
  default     = false

  validation {
    condition     = var.fifo_queue || var.content_based_deduplication == false
    error_message = "content_based_deduplication 只能在 fifo_queue = true 时启用"
  }
}

variable "visibility_timeout_seconds" {
  type        = number
  description = "消息可见性超时（秒）"
  default     = 30

  validation {
    condition     = var.visibility_timeout_seconds >= 0 && var.visibility_timeout_seconds <= 43200
    error_message = "visibility_timeout_seconds 必须在 0~43200 之间"
  }
}

variable "message_retention_seconds" {
  type        = number
  description = "消息保留时长（秒）"
  default     = 345600

  validation {
    condition     = var.message_retention_seconds >= 60 && var.message_retention_seconds <= 1209600
    error_message = "message_retention_seconds 必须在 60~1209600 之间"
  }
}

variable "delay_seconds" {
  type        = number
  description = "消息延迟（秒）"
  default     = 0

  validation {
    condition     = var.delay_seconds >= 0 && var.delay_seconds <= 900
    error_message = "delay_seconds 必须在 0~900 之间"
  }
}

variable "max_message_size" {
  type        = number
  description = "最大消息大小（字节）"
  default     = 262144

  validation {
    condition     = var.max_message_size >= 1024 && var.max_message_size <= 262144
    error_message = "max_message_size 必须在 1024~262144 之间"
  }
}

variable "receive_wait_time_seconds" {
  type        = number
  description = "长轮询等待时间（秒）"
  default     = 0

  validation {
    condition     = var.receive_wait_time_seconds >= 0 && var.receive_wait_time_seconds <= 20
    error_message = "receive_wait_time_seconds 必须在 0~20 之间"
  }
}

variable "kms_master_key_id" {
  type        = string
  description = "用于 SQS 加密的 KMS Key ARN"
  default     = null

  validation {
    condition = (
      var.kms_master_key_id == null ||
      can(regex("^arn:aws:kms:[a-z0-9-]+:\\d{12}:key\\/.+", var.kms_master_key_id))
    )
    error_message = "kms_master_key_id 必须是有效的 KMS Key ARN"
  }
}

variable "kms_data_key_reuse_period_seconds" {
  type        = number
  description = "KMS 数据密钥重用周期（秒）"
  default     = null

  validation {
    condition = (
      var.kms_data_key_reuse_period_seconds == null ||
      (var.kms_data_key_reuse_period_seconds >= 60 && var.kms_data_key_reuse_period_seconds <= 86400)
    )
    error_message = "kms_data_key_reuse_period_seconds 必须在 60~86400 之间"
  }
}

variable "sqs_managed_sse_enabled" {
  type        = bool
  description = "是否启用 SQS 托管加密（SSE-SQS）"
  default     = false
}

variable "policy" {
  type        = string
  description = "SQS 队列访问策略（JSON 字符串）"
  default     = null
}

variable "policy_file" {
  type        = string
  description = "SNS Topic Policy JSON 文件路径"
  default     = null
}

variable "redrive_policy" {
  type = object({
    dead_letter_target_arn = string
    max_receive_count      = number
  })
  description = "死信队列策略（可选）"
  default     = null

  validation {
    condition = (
      var.redrive_policy == null ||
      (
        can(regex("^arn:aws:sqs:[a-z0-9-]+:\\d{12}:.+$", var.redrive_policy.dead_letter_target_arn)) &&
        var.redrive_policy.max_receive_count > 0
      )
    )
    error_message = "redrive_policy 必须包含有效的 dead_letter_target_arn 和 max_receive_count > 0"
  }
}

variable "tags" {
  type        = map(string)
  description = "标签"
  default     = {}
}

variable "enable_minimal_policy" {
  type        = bool
  description = "是否自动生成最小权限 SQS Policy"
  default     = true
}

variable "allowed_publish_arns" {
  type        = list(string)
  description = "允许向队列发送消息的 ARN 列表（Lambda、SNS、EventBridge、IAM Role 等）"
  default     = []

  validation {
    condition = alltrue([
      for arn in var.allowed_publish_arns :
      can(regex("^arn:aws:[a-z0-9-]+:\\d{12}:.+$", arn))
    ])
    error_message = "allowed_publish_arns 必须是有效的 ARN"
  }
}

variable "allowed_publish_services" {
  type        = list(string)
  description = "允许发布消息的 AWS 服务（如 events.amazonaws.com）"
  default     = []

  validation {
    condition = alltrue([
      for s in var.allowed_publish_services :
      can(regex("^[a-z0-9.-]+\\.amazonaws\\.com$", s))
    ])
    error_message = "allowed_publish_services 必须是有效的 AWS 服务域名，例如 events.amazonaws.com"
  }
}


