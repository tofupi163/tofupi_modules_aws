# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table
resource "aws_dynamodb_table" "this" {
  name         = var.name
  billing_mode = var.billing_mode

  hash_key  = var.hash_key
  range_key = var.range_key

  # PROVISIONED 模式下才设置容量
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null

  dynamic "point_in_time_recovery" {
    for_each = var.point_in_time_recovery.enabled ? [var.point_in_time_recovery] : []
    content {
      enabled                 = point_in_time_recovery.value.enabled
      recovery_period_in_days = point_in_time_recovery.value.recovery_period_in_days
    }
  }

  # Attributes
  dynamic "attribute" {
    for_each = var.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  # Global Secondary Indexes
  dynamic "global_secondary_index" {
    for_each = var.global_secondary_index
    content {
      name            = global_secondary_index.value.name
      hash_key        = global_secondary_index.value.hash_key
      range_key       = global_secondary_index.value.range_key
      projection_type = global_secondary_index.value.projection_type

      read_capacity  = var.billing_mode == "PROVISIONED" ? global_secondary_index.value.read_capacity : null
      write_capacity = var.billing_mode == "PROVISIONED" ? global_secondary_index.value.write_capacity : null
    }
  }

  # Local Secondary Indexes
  dynamic "local_secondary_index" {
    for_each = var.local_secondary_index
    content {
      name            = local_secondary_index.value.name
      range_key       = local_secondary_index.value.range_key
      projection_type = local_secondary_index.value.projection_type
    }
  }

  # TTL
  dynamic "ttl" {
    for_each = var.ttl == null ? [] : [var.ttl]
    content {
      attribute_name = ttl.value.attribute_name
      enabled        = ttl.value.enabled
    }
  }

  # Streams
  stream_enabled   = var.stream_enabled
  stream_view_type = var.stream_view_type

  # Encryption
  dynamic "server_side_encryption" {
    for_each = var.server_side_encryption == null ? [] : [var.server_side_encryption]
    content {
      enabled     = server_side_encryption.value.enabled
      kms_key_arn = server_side_encryption.value.kms_key_arn
    }
  }

  tags = var.tags != null ? var.tags : {}
}
