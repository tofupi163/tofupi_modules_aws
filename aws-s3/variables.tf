// prevent destroy default true
variable "prevent_destroy" {
  type = bool
  default = true
}

variable "_tofupi" {
  description = "Tofupi 内部变量"
  type = map(object({}))
  default = {
    aws_s3_bucket = {
      # from tags
      nameKey = "bucket",
      projectID = "AssetID",
      exclude = [
        "arn",
        "bucket_regional_domain_name",
        "bucket_domain_name",
        "bucket_region",
        "hosted_zone_id",
        "id",
        "region",
        "request_payer",
        "policy",
        "acl",
      ]
    },
    aws_s3_bucket_policy = {
      nameKey = "bucket",
      link = "aws_s3_bucket.bucket_policy.bucket.id",
      policy = "policy",
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

variable "name" {
  type = string
  default = null
}

variable "short_name" {
  type = string
  default = null
}

variable "tags" {
  type = map(string)
  default = null
}

variable "force_destroy" {
  type = bool
  default = false
}

variable "grant" {
  type = map(object({
    # name = string
    type = string
    permissions = list(string)
  })) 
  default = {}
}

variable "object_lock_enabled" {
  type = bool
  default = false
}

variable "versioning" {
  type = map(object({
    enabled = optional(bool, false)
    mfa_delete = optional(bool, false)
  }))
  default = {}
}

variable "bucket_version" {
  type = bool
  default = null
}

variable "cors_rule" {
  type = list(object({
    allowed_headers = optional(list(string))
    allowed_methods = list(string)           # 必填
    allowed_origins = list(string)           # 必填
    expose_headers  = optional(list(string))
    max_age_seconds = optional(number)
  }))
  default = [] 
  validation {
    condition = alltrue([
      for rule in var.cors_rule : alltrue([
        for m in rule.allowed_methods : contains(["GET", "PUT", "POST", "DELETE", "HEAD"], m)
      ])
    ])
    error_message = "allowed_methods 只能为 'GET', 'PUT', 'POST', 'DELETE', 'HEAD'"
  }
}

variable "access_points" {
  description = "Map of access point names to create for the S3 bucket"
  type        = string
  default = null
}

variable "bucket_policy" {
  type = map(object({
    policy = optional(string, null)
    policy_file = optional(string, null)
  }))
  default = {}
}

# variable "policy" {
#   type        = string
#   default = null
# }

# variable "policy_file" {
#   type        = string
#   default = null
# }

variable "lifecycle_rule" {
  type = list(object({
    id     = string
    prefix = optional(string, "")
    status = string 
    transitions = optional(list(object({
      days          = number
      storage_class = string
    })), [])
  }))
  default = []
  validation {
    condition = alltrue([
      for r in var.lifecycle_rule : contains(["Enabled", "Disabled"], r.status)
    ])
    error_message = "status 指定的有效值为 'Enabled' 或 'Disabled'"
  }
  validation {
    condition = alltrue(flatten([
      for r in var.lifecycle_rule : [
        for t in r.transitions : contains([
          "GLACIER", "DEEP_ARCHIVE", "STANDARD_IA", "ONEZONE_IA", "INTELLIGENT_TIERING", "GLACIER_IR"
        ], t.storage_class)
      ]
    ]))
    error_message = "storage_class 指定的有效值为: GLACIER, DEEP_ARCHIVE, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, GLACIER_IR。"
  }
}


variable "server_side_encryption_configuration" {
  type = list(object({
    rule = optional(list(object({
      bucket_key_enabled = optional(string)
      apply_server_side_encryption_by_default = optional(list(object({
        kms_master_key_id = optional(string)
        sse_algorithm     = string
      })), [])
    })), [])
  }))
  default = []

  validation {
    condition = alltrue(flatten([
      for config in var.server_side_encryption_configuration : [
        for r in config.rule : [
          for crypto in r.apply_server_side_encryption_by_default : 
            contains(["AES256", "aws:kms"], crypto.sse_algorithm)
        ]
      ]
    ]))
    error_message = "sse_algorithm 只能是 'AES256' 或 'aws:kms' "
  }
}
