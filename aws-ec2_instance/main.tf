locals {
	base_tags = var.name == null ? {} : {
		Name = var.name
	}

	effective_tags = merge(
		var.tags == null ? {} : var.tags,
		local.base_tags,
	)
}

resource "aws_instance" "this" {
	ami           = var.ami
	instance_type = var.instance_type
	subnet_id     = var.subnet_id

	# availability_zone                   = var.availability_zone
	associate_public_ip_address         = var.associate_public_ip_address
	disable_api_stop                    = var.disable_api_stop
	disable_api_termination             = var.disable_api_termination
	ebs_optimized                       = var.ebs_optimized
	get_password_data                   = var.get_password_data
	hibernation                         = var.hibernation
	iam_instance_profile                = var.iam_instance_profile
	instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
	ipv6_address_count                  = var.ipv6_address_count
	key_name                            = var.key_name
	monitoring                          = var.monitoring
	private_ip                          = var.private_ip
	source_dest_check                   = var.source_dest_check
	tenancy                             = var.tenancy
	user_data_base64                    = var.user_data_base64

	vpc_security_group_ids = length(var.vpc_security_group_ids) > 0 ? var.vpc_security_group_ids : null

	tags = local.effective_tags

	dynamic "capacity_reservation_specification" {
		for_each = var.capacity_reservation_specification == null ? [] : [var.capacity_reservation_specification]
		content {
			capacity_reservation_preference = try(capacity_reservation_specification.value.capacity_reservation_preference, null)

			dynamic "capacity_reservation_target" {
				for_each = try(capacity_reservation_specification.value.capacity_reservation_target, null) == null ? [] : [capacity_reservation_specification.value.capacity_reservation_target]
				content {
					capacity_reservation_id                 = try(capacity_reservation_target.value.capacity_reservation_id, null)
					capacity_reservation_resource_group_arn = try(capacity_reservation_target.value.capacity_reservation_resource_group_arn, null)
				}
			}
		}
	}

	dynamic "cpu_options" {
		for_each = var.cpu_options == null ? [] : [var.cpu_options]
		content {
			core_count       = try(cpu_options.value.core_count, null)
			threads_per_core = try(cpu_options.value.threads_per_core, null)
		}
	}

	dynamic "credit_specification" {
		for_each = var.credit_specification == null ? [] : [var.credit_specification]
		content {
			cpu_credits = credit_specification.value.cpu_credits
		}
	}

	dynamic "enclave_options" {
		for_each = var.enclave_options == null ? [] : [var.enclave_options]
		content {
			enabled = enclave_options.value.enabled
		}
	}

	dynamic "instance_market_options" {
		for_each = var.instance_market_options == null ? [] : [var.instance_market_options]
		content {
			market_type = instance_market_options.value.market_type

			dynamic "spot_options" {
				for_each = try(instance_market_options.value.spot_options, null) == null ? [] : [instance_market_options.value.spot_options]
				content {
					instance_interruption_behavior = try(spot_options.value.instance_interruption_behavior, null)
					max_price                      = try(spot_options.value.max_price, null)
					spot_instance_type             = try(spot_options.value.spot_instance_type, null)
					valid_until                    = try(spot_options.value.valid_until, null)
				}
			}
		}
	}

	dynamic "launch_template" {
		for_each = var.launch_template == null ? [] : [var.launch_template]
		content {
			id      = try(launch_template.value.id, null)
			name    = try(launch_template.value.name, null)
			version = try(launch_template.value.version, null)
		}
	}

	dynamic "maintenance_options" {
		for_each = var.maintenance_options == null ? [] : [var.maintenance_options]
		content {
			auto_recovery = maintenance_options.value.auto_recovery
		}
	}

	dynamic "metadata_options" {
		for_each = var.metadata_options == null ? [] : [var.metadata_options]
		content {
			http_endpoint               = try(metadata_options.value.http_endpoint, null)
			http_protocol_ipv6          = try(metadata_options.value.http_protocol_ipv6, null)
			http_put_response_hop_limit = try(metadata_options.value.http_put_response_hop_limit, null)
			http_tokens                 = try(metadata_options.value.http_tokens, null)
			instance_metadata_tags      = try(metadata_options.value.instance_metadata_tags, null)
		}
	}

	dynamic "root_block_device" {
		for_each = var.root_block_device == null ? [] : [var.root_block_device]
		content {
			delete_on_termination = try(root_block_device.value.delete_on_termination, null)
			encrypted             = try(root_block_device.value.encrypted, null)
			iops                  = try(root_block_device.value.iops, null)
			kms_key_id            = try(root_block_device.value.kms_key_id, null)
			throughput            = try(root_block_device.value.throughput, null)
			volume_size           = try(root_block_device.value.volume_size, null)
			volume_type           = try(root_block_device.value.volume_type, null)
			tags                  = try(root_block_device.value.tags, {})
		}
	}

	dynamic "ebs_block_device" {
		for_each = var.ebs_block_devices
		content {
			device_name           = ebs_block_device.value.device_name
			delete_on_termination = try(ebs_block_device.value.delete_on_termination, null)
			encrypted             = try(ebs_block_device.value.encrypted, null)
			iops                  = try(ebs_block_device.value.iops, null)
			kms_key_id            = try(ebs_block_device.value.kms_key_id, null)
			snapshot_id           = try(ebs_block_device.value.snapshot_id, null)
			throughput            = try(ebs_block_device.value.throughput, null)
			volume_size           = try(ebs_block_device.value.volume_size, null)
			volume_type           = try(ebs_block_device.value.volume_type, null)
			tags                  = try(ebs_block_device.value.tags, {})
		}
	}
}
