variable "name" {
	type        = string
	description = "EC2 实例的逻辑名称，用于 Name 标签。"
	default     = null

	validation {
		condition     = var.name == null || length(trimspace(var.name)) > 0
		error_message = "name 不能为空字符串。"
	}
}


variable "_tofupi" {
  description = "Tofupi 内部变量"
  type = map(object({}))
  default = {
    aws_instance:{
      nameKey = "id"  # from private_ip,
      # from tags
      projectID = "AssetID",
      exclude = [
		"id",
		"arn",
		"cpu_options",
        "region",
		"private_dns",
		"prrivate_ip",
		"secondary_private_ips",
		"instance_state",
		"availability_zone",
		"maintenance_options",
		"placement_partition_number",
		"private_dns_name_options",
		"primary_network_interface",
		"primary_network_interface_id",
      ]
    }
  }
}

variable "tags" {
	type        = map(string)
	description = "附加到实例的额外标签。"
	default     = {}

	validation {
		condition = length(var.tags) == 0 ? true : alltrue([
			for entry in [for k, v in var.tags : {
				key   = trimspace(k)
				value = trimspace(v)
			}] :
			length(entry.key) > 0 && length(entry.value) > 0
		])
		error_message = "tags 中的 key/value 不能为空或全是空白。"
	}
}

variable "ami" {
	type        = string
	description = "用于实例的 AMI ID。"

	validation {
		condition     = can(regex("^ami-[0-9a-f]{8,}$", trimspace(var.ami)))
		error_message = "ami 必须是有效的 AMI ID (例如 ami-1234567890abcdef0)。"
	}
}

variable "instance_type" {
	type        = string
	description = "EC2 实例类型。"

	validation {
		condition     = can(regex("^[a-z0-9]+\\.[a-z0-9]+$", trimspace(var.instance_type)))
		error_message = "instance_type 必须符合例如 m7i.xlarge 的格式。"
	}
}

variable "subnet_id" {
	type        = string
	description = "实例所属子网。"

	validation {
		condition     = can(regex("^subnet-[0-9a-f]{8,}$", trimspace(var.subnet_id)))
		error_message = "subnet_id 必须是有效的子网 ID (subnet-********)。"
	}
}

# variable "availability_zone" {
# 	type        = string
# 	description = "实例放置的可用区。"
# 	default     = null

# 	validation {
# 		condition     = var.availability_zone == null || can(regex("^[a-z]{2}-[a-z]+-[0-9][a-z]$", var.availability_zone))
# 		error_message = "availability_zone 必须形如 us-east-2a。"
# 	}
# }

variable "associate_public_ip_address" {
	type        = bool
	description = "是否将公有 IP 关联到主网卡。"
	default     = null

	validation {
		condition     = var.associate_public_ip_address == null || contains([true, false], var.associate_public_ip_address)
		error_message = "associate_public_ip_address 只能是 true 或 false。"
	}
}

variable "disable_api_stop" {
	type        = bool
	description = "是否禁止 API Stop 操作。"
	default     = null

	validation {
		condition     = var.disable_api_stop == null || contains([true, false], var.disable_api_stop)
		error_message = "disable_api_stop 只能是 true 或 false。"
	}
}

variable "disable_api_termination" {
	type        = bool
	description = "是否禁止 API Termination 操作。"
	default     = null

	validation {
		condition     = var.disable_api_termination == null || contains([true, false], var.disable_api_termination)
		error_message = "disable_api_termination 只能是 true 或 false。"
	}
}

variable "ebs_optimized" {
	type        = bool
	description = "启用 EBS 优化实例。"
	default     = null

	validation {
		condition     = var.ebs_optimized == null || contains([true, false], var.ebs_optimized)
		error_message = "ebs_optimized 只能是 true 或 false。"
	}
}

variable "get_password_data" {
	type        = bool
	description = "是否检索 Windows 密码数据。"
	default     = null

	validation {
		condition     = var.get_password_data == null || contains([true, false], var.get_password_data)
		error_message = "get_password_data 只能是 true 或 false。"
	}
}

variable "hibernation" {
	type        = bool
	description = "是否启用休眠。"
	default     = null

	validation {
		condition     = var.hibernation == null || contains([true, false], var.hibernation)
		error_message = "hibernation 只能是 true 或 false。"
	}
}

variable "iam_instance_profile" {
	type        = string
	description = "要附加的 IAM 实例配置文件名。"
	default     = null

	validation {
		condition     = var.iam_instance_profile == null || length(trimspace(var.iam_instance_profile)) > 0
		error_message = "iam_instance_profile 不能为空字符串。"
	}
}

variable "instance_initiated_shutdown_behavior" {
	type        = string
	description = "实例自发关机后的行为。"
	default     = null

	validation {
		condition = var.instance_initiated_shutdown_behavior == null || contains([
			"stop",
			"terminate",
		], lower(var.instance_initiated_shutdown_behavior))
		error_message = "instance_initiated_shutdown_behavior 只能是 stop 或 terminate。"
	}
}

variable "ipv6_address_count" {
	type        = number
	description = "要分配的 IPv6 地址数量。"
	default     = null

	validation {
		condition     = var.ipv6_address_count == null || var.ipv6_address_count >= 0
		error_message = "ipv6_address_count 必须 >= 0。"
	}
}

variable "key_name" {
	type        = string
	description = "要关联的密钥对名称。"
	default     = null

	validation {
		condition     = var.key_name == null || length(trimspace(var.key_name)) > 0
		error_message = "key_name 不能为空字符串。"
	}
}

variable "monitoring" {
	type        = bool
	description = "启用 CloudWatch 详细监控。"
	default     = null

	validation {
		condition     = var.monitoring == null || contains([true, false], var.monitoring)
		error_message = "monitoring 只能是 true 或 false。"
	}
}

variable "private_ip" {
	type        = string
	description = "自定义私有 IPv4 地址。"
	default     = null

	validation {
		condition = var.private_ip == null || can(regex(
			"^(25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])$",
			var.private_ip
		))
		error_message = "private_ip 必须是合法 IPv4 地址。"
	}
}

variable "source_dest_check" {
	type        = bool
	description = "是否启用源/目的检查。"
	default     = null

	validation {
		condition     = var.source_dest_check == null || contains([true, false], var.source_dest_check)
		error_message = "source_dest_check 只能是 true 或 false。"
	}
}

variable "tenancy" {
	type        = string
	description = "实例租户模式。"
	default     = "default"

	validation {
		condition     = contains(["default", "dedicated", "host"], lower(var.tenancy))
		error_message = "tenancy 只能是 default、dedicated 或 host。"
	}
}

variable "user_data_base64" {
	type        = string
	description = "Base64 编码的启动脚本。"
	default     = null

	validation {
		condition     = var.user_data_base64 == null || var.user_data_base64 == "" || can(base64decode(var.user_data_base64))
		error_message = "user_data_base64 必须是有效的 Base64 字符串。"
	}
}

variable "vpc_security_group_ids" {
	type        = list(string)
	description = "要附加的安全组 ID 列表。"
	default     = []

	validation {
		condition = length(var.vpc_security_group_ids) == 0 ? true : alltrue([
			for sg in var.vpc_security_group_ids : can(regex("^sg-[0-9a-f]{8,}$", sg))
		])
		error_message = "vpc_security_group_ids 中的值必须是有效的 sg-******** ID。"
	}

	validation {
		condition     = length(var.vpc_security_group_ids) == length(distinct(var.vpc_security_group_ids))
		error_message = "vpc_security_group_ids 不能包含重复项。"
	}
}

variable "capacity_reservation_specification" {
	type = object({
		capacity_reservation_preference = optional(string)
		capacity_reservation_target = optional(object({
			capacity_reservation_id                 = optional(string)
			capacity_reservation_resource_group_arn = optional(string)
		}))
	})
	description = "容量预留配置。"
	default     = null

	validation {
		condition = var.capacity_reservation_specification == null ? true : (
			(
				try(var.capacity_reservation_specification.capacity_reservation_preference, null) == null
				|| contains(["open", "none"], lower(var.capacity_reservation_specification.capacity_reservation_preference))
			) && (
				try(var.capacity_reservation_specification.capacity_reservation_target, null) == null
				|| try(var.capacity_reservation_specification.capacity_reservation_target.capacity_reservation_id, null) != null
				|| try(var.capacity_reservation_specification.capacity_reservation_target.capacity_reservation_resource_group_arn, null) != null
			)
		)
		error_message = "capacity_reservation_specification 无效: preference 只能是 open/none，target 至少提供 ID 或 ARN。"
	}
}

variable "cpu_options" {
	type = object({
		core_count       = optional(number)
		threads_per_core = optional(number)
	})
	description = "CPU 拓扑设置。"
	default     = null

	validation {
		condition = var.cpu_options == null ? true : (
			(try(var.cpu_options.core_count, null) == null || var.cpu_options.core_count > 0)
			&& (try(var.cpu_options.threads_per_core, null) == null || contains([1, 2], var.cpu_options.threads_per_core))
		)
		error_message = "cpu_options.core_count 必须 > 0，threads_per_core 只能是 1 或 2。"
	}
}

variable "credit_specification" {
	type = object({
		cpu_credits = string
	})
	description = "T 系列实例的 CPU 积分模式。"
	default     = null

	validation {
		condition     = var.credit_specification == null || contains(["standard", "unlimited"], lower(var.credit_specification.cpu_credits))
		error_message = "credit_specification.cpu_credits 只能是 standard 或 unlimited。"
	}
}

variable "enclave_options" {
	type = object({
		enabled = bool
	})
	description = "Nitro Enclave 配置。"
	default     = null

	validation {
		condition     = var.enclave_options == null || contains([true, false], var.enclave_options.enabled)
		error_message = "enclave_options.enabled 只能是 true 或 false。"
	}
}

variable "instance_market_options" {
	type = object({
		market_type = string
		spot_options = optional(object({
			instance_interruption_behavior = optional(string)
			max_price                      = optional(string)
			spot_instance_type             = optional(string)
			valid_until                    = optional(string)
		}))
	})
	description = "实例市场配置 (Spot)。"
	default     = null

	validation {
		condition = var.instance_market_options == null ? true : (
			lower(var.instance_market_options.market_type) == "spot"
			&& (
				try(var.instance_market_options.spot_options.instance_interruption_behavior, null) == null
				|| contains(["terminate", "stop", "hibernate"], lower(var.instance_market_options.spot_options.instance_interruption_behavior))
			)
			&& (
				try(var.instance_market_options.spot_options.spot_instance_type, null) == null
				|| contains(["one-time", "persistent"], lower(var.instance_market_options.spot_options.spot_instance_type))
			)
		)
		error_message = "instance_market_options 必须将 market_type 设为 spot，spot 选项需使用合法枚举值。"
	}
}

variable "launch_template" {
	type = object({
		id      = optional(string)
		name    = optional(string)
		version = optional(string)
	})
	description = "要引用的 Launch Template。"
	default     = null

	validation {
		condition = var.launch_template == null ? true : (
			(try(var.launch_template.id, null) != null || try(var.launch_template.name, null) != null)
			&& (try(var.launch_template.version, null) == null || length(trimspace(var.launch_template.version)) > 0)
		)
		error_message = "launch_template 至少需要 id 或 name，version 不能为空。"
	}
}

variable "maintenance_options" {
	type = object({
		auto_recovery = string
	})
	description = "维护期选项。"
	default     = null

	validation {
		condition     = var.maintenance_options == null || contains(["default", "disabled"], lower(var.maintenance_options.auto_recovery))
		error_message = "maintenance_options.auto_recovery 只能是 default 或 disabled。"
	}
}

variable "metadata_options" {
	type = object({
		http_endpoint               = optional(string)
		http_protocol_ipv6          = optional(string)
		http_put_response_hop_limit = optional(number)
		http_tokens                 = optional(string)
		instance_metadata_tags      = optional(string)
	})
	description = "IMDS 配置。"
	default     = null

	validation {
		condition = var.metadata_options == null ? true : (
			(
				try(var.metadata_options.http_endpoint, null) == null
				|| contains(["enabled", "disabled"], lower(var.metadata_options.http_endpoint))
			) && (
				try(var.metadata_options.http_protocol_ipv6, null) == null
				|| contains(["enabled", "disabled"], lower(var.metadata_options.http_protocol_ipv6))
			) && (
				try(var.metadata_options.http_put_response_hop_limit, null) == null
				|| (var.metadata_options.http_put_response_hop_limit >= 1 && var.metadata_options.http_put_response_hop_limit <= 64)
			) && (
				try(var.metadata_options.http_tokens, null) == null
				|| contains(["required", "optional"], lower(var.metadata_options.http_tokens))
			) && (
				try(var.metadata_options.instance_metadata_tags, null) == null
				|| contains(["enabled", "disabled"], lower(var.metadata_options.instance_metadata_tags))
			)
		)
		error_message = "metadata_options 包含无效值；请检查 enabled/disabled、required/optional 以及 hop limit 范围。"
	}
}

variable "root_block_device" {
	type = object({
		delete_on_termination = optional(bool)
		encrypted             = optional(bool)
		iops                  = optional(number)
		kms_key_id            = optional(string)
		throughput            = optional(number)
		volume_size           = optional(number)
		volume_type           = optional(string)
		tags                  = optional(map(string), {})
	})
	description = "根卷配置。"
	default     = null

	validation {
		condition = var.root_block_device == null ? true : (
			(try(var.root_block_device.volume_size, null) == null || var.root_block_device.volume_size >= 1)
			&& (try(var.root_block_device.throughput, null) == null || var.root_block_device.throughput >= 0)
			&& (try(var.root_block_device.iops, null) == null || var.root_block_device.iops >= 0)
			&& (try(var.root_block_device.volume_type, null) == null || contains(["standard", "gp2", "gp3", "io1", "io2", "sc1", "st1"], lower(var.root_block_device.volume_type)))
			&& (try(var.root_block_device.kms_key_id, null) == null || can(regex("^arn:aws:kms:", var.root_block_device.kms_key_id)))
		)
		error_message = "root_block_device 配置无效 (大小必须 >=1，IOPS/throughput >=0，volume_type/kms_key_id 必须合法)。"
	}
}

variable "ebs_block_devices" {
	type = list(object({
		device_name           = string
		delete_on_termination = optional(bool)
		encrypted             = optional(bool)
		iops                  = optional(number)
		kms_key_id            = optional(string)
		snapshot_id           = optional(string)
		throughput            = optional(number)
		volume_size           = optional(number)
		volume_type           = optional(string)
		tags                  = optional(map(string), {})
	}))
	description = "额外附加的 EBS 卷。"
	default     = []

	validation {
		condition = length(var.ebs_block_devices) == 0 ? true : alltrue([
			for device in var.ebs_block_devices : (
				length(trimspace(device.device_name)) > 0
				&& (try(device.volume_size, null) == null || device.volume_size >= 1)
				&& (try(device.throughput, null) == null || device.throughput >= 0)
				&& (try(device.iops, null) == null || device.iops >= 0)
				&& (try(device.volume_type, null) == null || contains(["standard", "gp2", "gp3", "io1", "io2", "sc1", "st1"], lower(device.volume_type)))
				&& (try(device.kms_key_id, null) == null || can(regex("^arn:aws:kms:", device.kms_key_id)))
			)
		])
		error_message = "ebs_block_devices 配置无效，请检查 device_name 以及容量/类型。"
	}
}
