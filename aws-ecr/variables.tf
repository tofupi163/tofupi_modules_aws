// prevent destroy default true
variable "prevent_destroy" {
  type = bool
  default = true
}

variable "tags" {
  type        = map(string)
  default     = {}
}

variable "_tofupi" {
  description = "Tofupi 内部变量"
  type = map(object({}))
  default = {
    aws_ecr_repository = {
      nameKey = "name",
      # from tags
      projectID = "AssetID",
      exclude = [
        "arn",
        "id",
        "registry_id",
        "repository_url",
        "region",
      ]
    },
    aws_ecr_lifecycle_policy = {
      # nameKey = "repository_name",
      policy = "policy",
      link = "aws_ecr_repository.lifecycle_policy.repository.name",
    },
    aws_ecr_repository_policy = {
      # nameKey = "repository_name",
      policy = "policy",
      link = "aws_ecr_repository.repository_policy.repository.name",
    }
  }
}

variable "name" {
  type        = string
  description = "ECR repository name"

  validation {
    condition     = can(regex("^[a-z0-9._/-]+$", var.name))
    error_message = "ECR 名称只能包含小写字母、数字、点、下划线、斜杠和短横线."
  }
}

variable "image_tag_mutability" {
  type        = string
  default     = "MUTABLE"
  description = "Whether image tags can be overwritten"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability 必须是 MUTABLE 或 IMMUTABLE."
  }
}

# variable "scan_on_push" {
#   type        = bool
#   default     = true
#   description = "Enable ECR image scan on push"
# }

variable "encryption_type" {
  type        = string
  default     = "AES256"
  description = "ECR encryption type"

  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "encryption_type 必须是 AES256 或 KMS."
  }
}

variable "kms_key" {
  type        = string
  default     = null
  description = "KMS key ARN for encryption (required when encryption_type = KMS)"

  validation {
    condition = (
      var.encryption_type == "AES256"
      || (var.encryption_type == "KMS" && var.kms_key != null)
    )
    error_message = "当 encryption_type = KMS 时，必须提供 kms_key."
  }
}

variable "encryption_configuration" {
  type = map(object({
    encryption_type = string
    kms_key         = optional(string, null)
  }))
  default = {}
  description = "ECR encryption configuration"
}


variable "image_scanning_configuration" {
  type = map(object({
    scan_on_push = optional(bool, true)
  }))
  default = {}
  description = "ECR image scanning configuration (only scan_on_push supported)"
}

variable "lifecycle_policy" {
  type        = map(object({
    policy = optional(string,"")
    policy_file = optional(string,"")
  }))
  default     = null
  description = "JSON lifecycle policy for ECR"
}

variable "repository_policy" {
  type        = map(object({
    policy = optional(string,"")
    policy_file = optional(string,"")
  }))
  default     = null
  description = "JSON IAM policy for the ECR repository"
}

