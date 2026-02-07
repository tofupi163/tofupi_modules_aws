# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl
resource "aws_security_group" "this" {
  name        = "${var.name}-sg"
  description = var.description != null ? var.description : "Security Group for ${var.name}"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    // Skip block when ingress is null
    for_each = var.ingress != null ? var.ingress : []
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  dynamic "egress" {
    // Skip block when egress is null
    for_each = var.egress != null ? var.egress : []
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
      description = egress.value.description
    }
  }

  tags = merge(
    var.tags != null ? var.tags : {},
    {
      Name = var.name
    }
  )
}

resource "aws_security_group_rule" "rules" {
  for_each = { for idx, rule in (var.sg_rules != null ? var.sg_rules : []) : idx => rule }

  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
  description       = each.value.description
  security_group_id = aws_security_group.this.id
}

# resource "aws_security_group_rule" "egress" {
#   for_each = { for idx, rule in var.sg_egress : idx => rule }

#   type              = "egress"
#   from_port         = each.value.from_port
#   to_port           = each.value.to_port
#   protocol          = each.value.protocol
#   cidr_blocks       = each.value.cidr_blocks
#   description       = each.value.description
#   security_group_id = aws_security_group.this.id
# }
