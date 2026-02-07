# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/ephemeral-resources/ssm_parameter
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  full_name = "/${var.asset_id}/${var.short_name}/${var.asset_group}"
}

resource "aws_ssm_parameter" "this" {
  name = var.name != null ? var.name : local.full_name
  lifecycle {
    prevent_destroy = true
  }
  arn  = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${var.name != null ? var.name : local.full_name}"
  type = var.type
  value = var.value_file != null ? file("${path.root}/data/${var.asset_group}_ssm_${var.value_file}") : var.value
  tags = var.tags != null ? var.tags : {}
  tier = var.tier
  data_type = var.data_type
  key_id = var.data_type == "SecureString" ? var.key_id : null
  description = var.description != null ? var.description : null
}
