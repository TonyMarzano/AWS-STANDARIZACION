# Transit Gateway central de la arquitectura de red de referencia.
#
# Una sola route table, asociada a TODOS los attachments (Networking + cada spoke):
# - Cada spoke (Prod, Dev, etc.) propaga su propio CIDR -> el tráfico entre spokes viaja
#   directo por el Transit Gateway, sin pasar por la cuenta Networking.
# - La cuenta Networking NO propaga nada (no tiene un CIDR que los demás necesiten alcanzar
#   por default) — en su lugar, el env que compone este módulo agrega una ruta ESTÁTICA
#   0.0.0.0/0 -> attachment de Networking, una vez que ese attachment existe (ver
#   envs/networking/network/main.tf). Así cualquier tráfico sin ruta más específica (asumido
#   Internet) sale por el NAT Gateway centralizado de la cuenta Networking.
#
# La asociación/propagación por default del Transit Gateway queda deshabilitada: cada
# attachment se asocia y propaga explícitamente vía el módulo tgw-attachment.

resource "aws_ec2_transit_gateway" "this" {
  description                     = "${var.name} - hub de red centralizado"
  amazon_side_asn                 = var.amazon_side_asn
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

  tags = { Name = var.name }
}

resource "aws_ec2_transit_gateway_route_table" "main" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id

  tags = { Name = "${var.name}-rt" }
}

# --- Compartir el Transit Gateway con las cuentas spoke vía AWS RAM ---

resource "aws_ram_resource_share" "this" {
  name                      = "${var.name}-share"
  allow_external_principals = false

  tags = { Name = "${var.name}-share" }
}

resource "aws_ram_resource_association" "tgw" {
  resource_arn       = aws_ec2_transit_gateway.this.arn
  resource_share_arn = aws_ram_resource_share.this.arn
}

resource "aws_ram_principal_association" "spokes" {
  count              = length(var.spoke_account_ids)
  principal          = var.spoke_account_ids[count.index]
  resource_share_arn = aws_ram_resource_share.this.arn
}
