locals {
  attachment_subnet_keys = [for k, s in var.subnets : k if s.tier == "attachment"]

  no_routes = { igw_cidrs = [], tgw_cidrs = [] }

  igw_routes = merge([
    for sk, s in var.subnets : {
      for c in lookup(var.tiers, s.tier, local.no_routes).igw_cidrs : "${sk}|${c}" => { subnet_key = sk, cidr = c }
    }
  ]...)

  tgw_routes = merge([
    for sk, s in var.subnets : {
      for c in lookup(var.tiers, s.tier, local.no_routes).tgw_cidrs : "${sk}|${c}" => { subnet_key = sk, cidr = c }
    }
  ]...)

  eni_routes = { for k, r in var.eni_routes : k => r if r.network_interface_id != null }
}

resource "aws_vpc" "this" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = var.name }
}

# Se vacía el SG default (CIS): ningún recurso debe depender de él.
resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.this.id

  tags = { Name = replace(var.name, "vpc_", "sg-default_") }
}

resource "aws_internet_gateway" "this" {
  count = var.create_internet_gateway ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = { Name = replace(var.name, "vpc_", "igw_") }
}

resource "aws_subnet" "this" {
  for_each = var.subnets

  vpc_id               = aws_vpc.this.id
  cidr_block           = each.value.cidr
  availability_zone_id = each.value.az_id

  tags = { Name = each.value.name }
}

resource "aws_route_table" "this" {
  for_each = var.subnets

  vpc_id = aws_vpc.this.id

  tags = { Name = replace(each.value.name, "subnet_", "rt_") }
}

resource "aws_route_table_association" "this" {
  for_each = var.subnets

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.this[each.key].id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  count = var.attach_to_transit_gateway ? 1 : 0

  transit_gateway_id = var.transit_gateway_id
  vpc_id             = aws_vpc.this.id
  subnet_ids         = [for k in local.attachment_subnet_keys : aws_subnet.this[k].id]

  appliance_mode_support = var.appliance_mode ? "enable" : "disable"
  dns_support            = "enable"

  # El ruteo del TGW se maneja explícitamente en el TGW (default association/propagation deshabilitados).
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = { Name = replace(var.name, "vpc_", "tgw-attach_") }
}

resource "aws_route" "igw" {
  for_each = local.igw_routes

  route_table_id         = aws_route_table.this[each.value.subnet_key].id
  destination_cidr_block = each.value.cidr
  gateway_id             = aws_internet_gateway.this[0].id
}

resource "aws_route" "tgw" {
  for_each = local.tgw_routes

  route_table_id         = aws_route_table.this[each.value.subnet_key].id
  destination_cidr_block = each.value.cidr
  # Referenciar el attachment (y no var.transit_gateway_id) fuerza a crear la ruta después del attachment.
  transit_gateway_id = aws_ec2_transit_gateway_vpc_attachment.this[0].transit_gateway_id
}

resource "aws_route" "eni" {
  for_each = local.eni_routes

  route_table_id         = aws_route_table.this[each.value.subnet_key].id
  destination_cidr_block = each.value.cidr
  network_interface_id   = each.value.network_interface_id

  # El failover HA del FortiGate re-apunta la ruta a la ENI del nodo activo; Terraform no debe revertirlo.
  lifecycle {
    ignore_changes = [network_interface_id]
  }
}
