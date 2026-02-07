# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint

data "aws_caller_identity" "current" {}

resource "aws_vpc_endpoint" "this" {
  vpc_id            = var.vpc_id
  service_name      = var.service_name
  vpc_endpoint_type = var.vpc_endpoint_type

  dynamic "dns_options" {
    for_each = length(var.dns_options) > 0 ? [var.dns_options] : []
    content {
      dns_record_ip_type                             = dns_options.value.dns_record_ip_type
      private_dns_only_for_inbound_resolver_endpoint = dns_options.value.private_dns_only_for_inbound_resolver_endpoint
    }
  }

  # Interface 类型
  subnet_ids          = var.vpc_endpoint_type == "Interface" ? var.subnet_ids : null
  security_group_ids  = local.final_security_group_ids
  private_dns_enabled = var.vpc_endpoint_type == "Interface" ? var.private_dns_enabled : null
  ip_address_type =  var.vpc_endpoint_type == "Interface" ? var.ip_address_type : null

  # Gateway 类型
  route_table_ids = var.vpc_endpoint_type == "Gateway" ? var.route_table_ids : null

  dynamic "cidr_blocks" {
    for_each = var.vpc_endpoint_type == "Gateway" && length(var.cidr_blocks) > 0 ? [var.cidr_blocks] : []
    content {
      cidr_blocks = cidr_blocks.value
    }
  }

  dynamic "subnet_configuration" {
    for_each = var.vpc_endpoint_type == "Interface" && length(var.subnet_configuration) > 0 ? var.subnet_configuration : []
    content {
      subnet_id            = subnet_configuration.value.subnet_id
      ipv4      = subnet_configuration.value.ipv4 ? "ipv4" : null
      ipv6      = subnet_configuration.value.ipv6 ? "ipv6" : null
    }
  }

  policy = local.final_policy_json

  tags = var.tags

  lifecycle {
    ignore_changes = [
      policy,
    ]
  }
}

resource "aws_security_group" "endpoint" {
  count = var.vpc_endpoint_type == "Interface" ? 1 : 0

  name        = "vpce-${local.endpoints_service}"
  description = "Auto-generated SG for ${var.service_name}"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = local.final_ingress
    content {
      from_port        = ingress.value.from_port
      to_port          = ingress.value.to_port
      protocol         = ingress.value.protocol
      cidr_blocks      = lookup(ingress.value, "cidr_blocks", [])
      ipv6_cidr_blocks = lookup(ingress.value, "ipv6_cidr_blocks", [])
      security_groups  = lookup(ingress.value, "security_groups", [])
      description      = lookup(ingress.value, "description", null)
    }
  }

  dynamic "egress" {
    for_each = local.final_egress
    content {
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = egress.value.protocol
      cidr_blocks      = lookup(egress.value, "cidr_blocks", [])
      ipv6_cidr_blocks = lookup(egress.value, "ipv6_cidr_blocks", [])
      security_groups  = lookup(egress.value, "security_groups", [])
      description      = lookup(egress.value, "description", null)
    }
  }

  tags = var.tags
}


data "aws_iam_policy_document" "interface_minimal" {
  count = var.enable_minimal_policy && var.vpc_endpoint_type == "Interface" ? 1 : 0

  # 当前账号 root
  statement {
    sid = "AllowAccountRootAccess"

    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }

    actions   = local.interface_actions
    resources = ["*"]
  }

  # 指定 IAM ARN
  statement {
    sid = "AllowSpecificIAMAccess"

    principals {
      type        = "AWS"
      identifiers = var.allowed_principal_arns
    }

    actions   = local.interface_actions
    resources = ["*"]
  }

  # AWS 服务
  statement {
    sid = "AllowAWSServiceAccess"

    principals {
      type        = "Service"
      identifiers = var.allowed_service_principals
    }

    actions   = local.interface_actions
    resources = ["*"]
  }
}


data "aws_iam_policy_document" "interface_minimal" {
  count = var.enable_minimal_policy && var.vpc_endpoint_type == "Interface" ? 1 : 0

  statement {
    sid = "AllowAccountRootAccess"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions = [
      "ec2:DescribeVpcEndpoints",
      "ec2:DescribeVpcEndpointServices",
      "ec2:DescribeVpcEndpointConnections"
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "gateway_minimal" {
  count = var.enable_minimal_policy && var.vpc_endpoint_type == "Gateway" ? 1 : 0

  statement {
    sid = "AllowAccountRootAccess"

    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }

    actions   = local.gateway_actions
    resources = ["*"]
  }

  # 允许指定 IAM ARN
  statement {
    sid = "AllowSpecificIAMAccess"

    principals {
      type        = "AWS"
      identifiers = var.allowed_principal_arns
    }

    actions   = local.gateway_actions
    resources = ["*"]
  }

  # 允许 AWS 服务访问
  statement {
    sid = "AllowAWSServiceAccess"

    principals {
      type        = "Service"
      identifiers = var.allowed_service_principals
    }

    actions   = local.gateway_actions
    resources = ["*"]
  }
}

