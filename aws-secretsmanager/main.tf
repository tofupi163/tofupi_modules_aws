# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret

locals {
  final_kms_key_id = var.create_kms_key ? aws_kms_key.this[0].arn : var.kms_key_id
  final_secret_data = merge(
    var.secret_data,
    var.create_random_password ? { password = random_password.this[0].result } : {}
  )
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = jsonencode(local.final_secret_data)

  lifecycle {
    ignore_changes = [
      secret_string,
    ]
  }
}

resource "random_password" "this" {
  count = var.create_random_password ? 1 : 0

  length           = var.random_password_length
  special          = true
  override_special = "!@#$%^&*()-_=+[]{}<>?"
}

resource "aws_kms_key" "this" {
  count = var.create_kms_key ? 1 : 0

  description         = "KMS key for secret ${var.name}"
  enable_key_rotation = true

  tags = var.tags

  lifecycle {
    ignore_changes = [
      policy,
    ]
  }
}

resource "aws_kms_alias" "this" {
  count = var.create_kms_key ? 1 : 0

  name          = "alias/${var.name}"
  target_key_id = aws_kms_key.this[0].key_id
}

resource "aws_secretsmanager_secret" "this" {
  name        = var.name
  description = var.description

  kms_key_id = local.final_kms_key_id

  tags = var.tags

  lifecycle {
    ignore_changes = [
      rotation_rules,
      kms_key_id,
    ]
  }
}
