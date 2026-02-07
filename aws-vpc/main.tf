# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "this" {
  cidr_block       = var.cidr_block
  enable_dns_hostnames                 = var.enable_dns_hostnames
  enable_dns_support                   = var.enable_dns_support
  enable_network_address_usage_metrics = var.enable_network_address_usage_metrics
  instance_tenancy                     = var.instance_tenancy

  ipv6_netmask_length = var.ipv6_netmask_length > 0 ? var.ipv6_netmask_length : null
  assign_generated_ipv6_cidr_block = var.assign_generated_ipv6_cidr_block

  tags = merge(
    var.tags != null ? var.tags : {},
    {
      Name = var.name
    }
  )
}

resource "aws_vpc_dhcp_options" "this" {
  count = length(var.dhcp_options) == 0 ? 0 : 1

  domain_name          = var.dhcp_options.domain_name
  domain_name_servers  = var.dhcp_options.domain_name_servers
  ntp_servers          = var.dhcp_options.ntp_servers
  netbios_name_servers = var.dhcp_options.netbios_name_servers
  netbios_node_type    = var.dhcp_options.netbios_node_type

  tags = {
    Name = "${var.name}-dhcp-options"
  }
}

resource "aws_vpc_dhcp_options_association" "this" {
  count = length(var.dhcp_options) == 0 ? 0 : 1

  vpc_id          = aws_vpc.this.id
  dhcp_options_id = aws_vpc_dhcp_options.this[0].id
}

