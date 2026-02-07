// prevent destroy default true
variable "prevent_destroy" {
  type = bool
  default = true
}

variable "_tofupi" {
  description = "Tofupi 内部变量"
  type = map(object({}))
  default = {
    aws_sns_topic = {
      # nameKey = "name",
      policy = "policy",
      projectID = "AssetID",
      exclude = [
        "arn",
        "id",
        "region",
        "owner",
      ]
    },
    aws_sns_topic_subscription = {
      nameKey = "id",
      policy = "filter_policy",
      link = "aws_sns_topic.subscriptions.topic_arn.arn",
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

variable "name" {
  type        = string
  description = "SNS Topic 名称"

  validation {
    condition     = length(var.name) > 0
    error_message = "name 不能为空"
  }
}

variable "display_name" {
  type        = string
  description = "SNS Topic 显示名称"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "SNS Topic 标签"
  default     = {}
}

variable "firehose_success_feedback_sample_rate" {
  type = number
  default = 0
}

variable "content_based_deduplication" {
  type = bool
  default = false
}

variable "fifo_topic" {
  type = bool
  default = false
}

variable "http_success_feedback_sample_rate" {
  type = number
  default = 0
}

variable "sqs_success_feedback_sample_rate" {
  type = number
  default = 0
}

variable "lambda_success_feedback_sample_rate" {
  type = number
  default = 0
}

variable "application_success_feedback_sample_rate" {
  type = number
  default = 0
}

variable "signature_version" {
  type = number
  default = 0
}

variable "kms_master_key_id" {
  type        = string
  description = "用于 SNS Topic 加密的 KMS Key ARN"
  default = ""
  # validation {
  #   condition     = can(regex("^arn:aws:kms:[a-z0-9-]+:\\d{12}:key\\/.+", var.kms_master_key_id))
  #   error_message = "kms_master_key_id 必须是有效的 KMS Key ARN"
  # }
}

variable "policy" {
  type        = string
  description = "SNS Topic Policy JSON 字符串"
  default     = null
}

variable "policy_file" {
  type        = string
  description = "SNS Topic Policy JSON 文件路径"
  default     = null
}

variable "delivery_policy" {
  type        = string
  description = "SNS Delivery Policy JSON 字符串"
  default     = null
}

variable "subscriptions" {
  description = "SNS Topic 订阅列表"
  type = list(object({
    protocol              = string
    endpoint              = string
    filter_policy         = optional(string)
    policy_file         = optional(string, null)
    raw_message_delivery  = optional(bool)
  }))
  default = []

  validation {
    condition = alltrue([
      for s in var.subscriptions :
      contains(["email", "email-json", "lambda", "sqs", "http", "https", "sms", "application"], s.protocol)
    ])
    error_message = "subscriptions[*].protocol 必须是 email/email-json/lambda/sqs/http/https/sms/application 之一"
  }

  validation {
    condition = alltrue([
      for s in var.subscriptions :
      length(s.endpoint) > 0
    ])
    error_message = "subscriptions[*].endpoint 不能为空"
  }
}

variable "enable_minimal_policy" {
  type        = bool
  description = "是否启用 SNS Topic 最小权限策略"
  default     = true
}

variable "allowed_publish_services" {
  type        = list(string)
  description = "允许发布消息的 AWS 服务（如 sns.amazonaws.com、events.amazonaws.com）"
  default     = []

  validation {
    condition = alltrue([
      for s in var.allowed_publish_services :
      can(regex("^[a-z0-9.-]+\\.amazonaws\\.com$", s))
    ])
    error_message = "allowed_publish_services 必须是有效的 AWS 服务域名，例如 events.amazonaws.com"
  }
}

variable "allowed_subscriber_arns" {
  type        = list(string)
  description = "允许订阅 SNS Topic 的 IAM Role / Lambda / SQS ARN 列表"
  default     = []

  validation {
    condition = alltrue([
      for arn in var.allowed_subscriber_arns :
      can(regex("^arn:aws:[a-z0-9-]+:\\d{12}:.+$", arn))
    ])
    error_message = "allowed_subscriber_arns 必须是有效的 ARN"
  }
}

variable "tracing_config" {
  type        = string
  description = "SNS X-Ray 分布式追踪配置，可选 PassThrough 或 Active"
  default     = "PassThrough"

  validation {
    condition     = contains(["PassThrough", "Active"], var.tracing_config)
    error_message = "tracing_config 必须是 PassThrough 或 Active"
  }
}
