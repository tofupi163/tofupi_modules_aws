# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl
resource "aws_network_acl" "this" {
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.nacl_ingress
    content {
      rule_no    = ingress.value.rule_no
      protocol   = ingress.value.protocol
      action     = ingress.value.action
      cidr_block = ingress.value.cidr_block
      from_port  = ingress.value.from_port
      to_port    = ingress.value.to_port
    }
  }

  dynamic "egress" {
    for_each = var.nacl_egress
    content {
      rule_no    = egress.value.rule_no
      protocol   = egress.value.protocol
      action     = egress.value.action
      cidr_block = egress.value.cidr_block
      from_port  = egress.value.from_port
      to_port    = egress.value.to_port
    }
  }
  
  subnet_ids = length(var.subnet_ids) > 0 ? var.subnet_ids : null

  tags = merge(
    var.tags != null ? var.tags : {},
    {
      Name = var.name
    }
  )
}
