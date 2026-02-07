// prevent destroy default true
variable "prevent_destroy" {
  type = bool
  default = true
}

variable "tags" {
  type = map(string)
  default = null
}

variable "_tofupi" {
  description = "Tofupi 内部变量"
  type = map(object({}))
  default = {
    aws_ebs_volume = {
      nameKey = "id",
      # from tags
      projectID = "AssetID",
      exclude = [
        "arn",
        "id",
        "region",
        "create_time",
        "availability_zone",
      ]
    },
    aws_volume_attachment = {
      nameKey = "id",
      # from tags
      link = "aws_ebs_volume.volume_attachments.volume_id.id",
    },
  }
}

variable "name" {
  type        = string
  description = "EBS volume logical names"
}
variable "availability_zone" {
  type        = string
  description = "The availability zone for the EBS volume"
}

variable "size" {
  type        = number
  description = "Size of the EBS volume in GiB"

  validation {
    condition     = var.size >= 1
    error_message = "EBS 卷大小必须 >= 1 GiB."
  }
}

variable "type" {
  type        = string
  default     = "gp3"
  description = "EBS volume type"

  validation {
    condition = contains(["gp2", "gp3", "io1", "io2", "sc1", "st1", "standard"], var.type)
    error_message = "EBS type 必须是 gp2、gp3、io1、io2、sc1、st1 或 standard."
  }
}

variable "encrypted" {
  type        = bool
  default     = true
}

variable "kms_key_id" {
  type        = string
  default     = null

  validation {
    condition = (
      var.encrypted == false
      || var.kms_key_id == null
      || can(regex("^arn:aws:kms:", var.kms_key_id))
    )
    error_message = "kms_key_id 必须是有效的 KMS ARN."
  }
}

variable "iops" {
  type        = number
  default     = null
  description = "IOPS for io1/io2 volumes"

  validation {
    condition = (
      contains(["io1", "io2"], var.type)
      ? var.iops != null
      : var.iops == null
    )
    error_message = "当 type 为 io1 或 io2 时，必须提供 iops；其他类型不能提供 iops."
  }
}

variable "throughput" {
  type        = number
  default     = null
  description = "Throughput for gp3 volumes"

  validation {
    condition = (
      var.type == "gp3"
      ? (var.throughput == null || var.throughput >= 125)
      : var.throughput == null
    )
    error_message = "gp3 throughput 必须 >= 125；非 gp3 类型不能提供 throughput."
  }
}

variable "snapshot_id" {
  type        = string
  default     = null
}


variable "volume_attachments" {
  type = map(object({
    instance_id = string
    device_name = string
    # volume_id   = string
    force_detach = optional(bool, false)
  }))
  default = null
}


variable "multi_attach_enabled" {
  type = bool
  default = false
}

variable "volume_initialization_rate" {
  type = number
  default = 0
}