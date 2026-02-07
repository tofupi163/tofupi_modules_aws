locals {
  final_policy_json = var.enable_minimal_policy ? (
    var.vpc_endpoint_type == "Interface"
      ? data.aws_iam_policy_document.interface_minimal[0].json
      : data.aws_iam_policy_document.gateway_minimal[0].json
  ) : var.policy
}

locals {
  final_security_group_ids = var.vpc_endpoint_type == "Interface" ? (
    var.create_security_group
      ? [aws_security_group.endpoint[0].id]
      : var.security_group_ids
  ) : null
}

locals {
  # 提取 service_name 最后一个段，例如 s3 / dynamodb / sqs
  endpoints_service = lower(regex("^com\\.amazonaws\\.[a-z0-9-]+\\.([a-z0-9-]+)$", var.service_name)[0])
}

locals {
  interface_service_actions_map = {
    ssm             = ["ssm:DescribeParameters", "ssm:GetParameter", "ssm:GetParameters", "ssm:GetParametersByPath"]
    ec2             = ["ec2:DescribeInstances", "ec2:DescribeNetworkInterfaces", "ec2:DescribeSubnets", "ec2:DescribeVpcs"]
    ecr             = ["ecr:GetAuthorizationToken", "ecr:BatchCheckLayerAvailability", "ecr:GetDownloadUrlForLayer", "ecr:BatchGetImage"]
    secretsmanager  = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret", "secretsmanager:ListSecrets"]
    logs            = ["logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogStreams"]
    kms             = ["kms:DescribeKey", "kms:Encrypt", "kms:Decrypt", "kms:GenerateDataKey"]
  }
}

locals {
  interface_actions = lookup(
    local.interface_service_actions_map,
    local.endpoints_service,
    ["*"] # fallback
  )
}

locals {
  gateway_service_actions_map = {
    s3           = ["s3:*"]
    dynamodb     = ["dynamodb:*"]
    sqs          = ["sqs:*"]
    sns          = ["sns:*"]
    kinesis      = ["kinesis:*"]
    ecr          = ["ecr:*"]
    ecrapi       = ["ecr:*"]
    ecrdkr       = ["ecr:*"]
    ssmmessages  = ["ssmmessages:*"]
    ec2messages  = ["ec2messages:*"]
    logs         = ["logs:*"]
  }
}

locals {
  gateway_actions = lookup(
    local.gateway_service_actions_map,
    local.endpoints_service,
    ["*"] # fallback
  )
}

locals {
  default_ingress = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8"]
    }
  ]

  default_egress = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  final_ingress = length(var.security_group.ingress) > 0 ? var.security_group.ingress : local.default_ingress
  final_egress = length(var.security_group.egress) > 0 ? var.security_group.egress : local.default_egress
  
}
