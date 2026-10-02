# Transit Gateway centralizado en la cuenta Network + ruteo.
#
# Modelo de inspección centralizada (2 route tables):
#
#   rt_spokes      asociada a: Shared, Prod, QA
#                  rutas:      0.0.0.0/0 -> attachment de Networking (FortiGate)
#                  => todo el tráfico de los spokes (Internet, on-prem y spoke<->spoke) pasa por inspección.
#
#   rt_inspection  asociada a: Networking
#                  rutas:      CIDR de cada spoke (propagado)
#                  => el tráfico ya inspeccionado vuelve al spoke destino.
#
# Los spokes NO propagan a rt_spokes, por eso no se ven entre sí sin pasar por el firewall.

resource "aws_ec2_transit_gateway" "this" {
  provider = aws.network

  description     = "Transit Gateway central de ${var.cliente}"
  amazon_side_asn = var.amazon_side_asn

  auto_accept_shared_attachments  = "enable" # los attachments de las otras cuentas quedan disponibles sin aceptación manual
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = { Name = "tgw_${var.region}_networking" }
}

# ------------------------------------------------------------------ Compartir el TGW con la Organization

data "aws_organizations_organization" "this" {}

resource "aws_ram_sharing_with_organization" "this" {
  count = var.manage_ram_org_sharing ? 1 : 0
}

resource "aws_ram_resource_share" "tgw" {
  provider = aws.network

  name                      = "ram_${var.region}_networking_tgw"
  allow_external_principals = false

  tags = { Name = "ram_${var.region}_networking_tgw" }
}

resource "aws_ram_resource_association" "tgw" {
  provider = aws.network

  resource_arn       = aws_ec2_transit_gateway.this.arn
  resource_share_arn = aws_ram_resource_share.tgw.arn
}

resource "aws_ram_principal_association" "org" {
  provider = aws.network

  principal          = data.aws_organizations_organization.this.arn
  resource_share_arn = aws_ram_resource_share.tgw.arn

  depends_on = [aws_ram_sharing_with_organization.this]
}

# El share tarda unos segundos en ser visible en las cuentas miembro.
resource "time_sleep" "ram_propagation" {
  create_duration = "30s"

  depends_on = [
    aws_ram_resource_association.tgw,
    aws_ram_principal_association.org,
  ]
}

# ------------------------------------------------------------------ Route tables

resource "aws_ec2_transit_gateway_route_table" "spokes" {
  provider = aws.network

  transit_gateway_id = aws_ec2_transit_gateway.this.id

  tags = { Name = "tgw-rt_${var.region}_spokes" }
}

resource "aws_ec2_transit_gateway_route_table" "inspection" {
  provider = aws.network

  transit_gateway_id = aws_ec2_transit_gateway.this.id

  tags = { Name = "tgw-rt_${var.region}_inspection" }
}

locals {
  spoke_attachment_ids = {
    shared         = module.vpc_shared.transit_gateway_attachment_id
    workloads_prod = module.vpc_workloads_prod.transit_gateway_attachment_id
    workloads_qa   = module.vpc_workloads_qa.transit_gateway_attachment_id
  }
}

# Networking -> rt_inspection
resource "aws_ec2_transit_gateway_route_table_association" "networking" {
  provider = aws.network

  transit_gateway_attachment_id  = module.vpc_networking.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection.id
}

# Spokes -> rt_spokes
resource "aws_ec2_transit_gateway_route_table_association" "spokes" {
  provider = aws.network
  for_each = local.spoke_attachment_ids

  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spokes.id
}

# Los spokes propagan su CIDR a rt_inspection (ruta de retorno)
resource "aws_ec2_transit_gateway_route_table_propagation" "spokes_to_inspection" {
  provider = aws.network
  for_each = local.spoke_attachment_ids

  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection.id
}

# Default route de los spokes hacia la VPC de inspección
resource "aws_ec2_transit_gateway_route" "spokes_default" {
  provider = aws.network

  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = module.vpc_networking.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spokes.id

  depends_on = [aws_ec2_transit_gateway_route_table_association.networking]
}
