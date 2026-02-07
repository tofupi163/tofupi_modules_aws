# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/main_route_table_association
resource "aws_route_table" "this" {
  vpc_id = var.vpc_id
  dynamic "route" {
    for_each = var.routes != null ? var.routes : []
    content {
      cidr_block                 = lookup(route.value, "cidr_block", null)
      ipv6_cidr_block            = lookup(route.value, "ipv6_cidr_block", null)
      gateway_id                 = lookup(route.value, "gateway_id", null)
      nat_gateway_id             = lookup(route.value, "nat_gateway_id", null)
      transit_gateway_id         = lookup(route.value, "transit_gateway_id", null)
      vpc_peering_connection_id  = lookup(route.value, "vpc_peering_connection_id", null)
    }
  }
  propagating_vgws = var.propagating_vgws != null ? var.propagating_vgws : []
  tags = merge(
    var.tags != null ? var.tags : {},
    {
      Name = var.name
    }
  )
}

// 根据var.main_table_association创建多个resource "aws_main_route_table_association"资源

resource "aws_main_route_table_association" "this" {
  for_each = var.main_table_association != null ? { for idx, assoc in var.main_table_association : idx => assoc } : {}

  route_table_id = aws_route_table.this.id
  vpc_id         = each.value.vpc_id
}


resource "aws_route_table_association" "this" {
  for_each = var.table_association != null ? { for idx, assoc in var.table_association : idx => assoc } : {}

  route_table_id = aws_route_table.this.id
  subnet_id      = lookup(each.value, "subnet_id", null)
  gateway_id     = lookup(each.value, "gateway_id", null)
  # vpc_id         = each.value.vpc_id
}
