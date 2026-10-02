# Componente "network" de la cuenta Networking: Transit Gateway + VPC con salida centralizada
# a Internet (NAT). Se despliega ANTES que envs/prod/network y envs/nonprod/network — ambos
# necesitan el Transit Gateway ID y la route table que crea este componente, y sus cuentas
# deben aceptar la invitación de RAM antes de poder crear su propio attachment (ver README
# de este repo).
#
# Los módulos "vpc", "transit-gateway" y "tgw-attachment" viven en el repo terraform-modules-bgh
# (todavía no creado al momento de escribir este skeleton — ver docs/03-workloads/03-modulos-reutilizables.md).
# Reemplazar el "source" de abajo por la referencia real con ?ref=vX.Y.Z una vez exista el módulo.
#
# Diseño completo (por qué una sola TGW route table, cómo viaja el tráfico Prod<->Dev y
# Prod/Dev->Internet) en docs/03-workloads/05-arquitectura-red-referencia.md.

module "transit_gateway" {
  source = "git::https://github.com/<org-bgh>/terraform-modules-bgh.git//modules/transit-gateway?ref=v1.0.0"

  name              = "${var.cliente}-tgw"
  spoke_account_ids = var.spoke_account_ids
}

module "vpc" {
  source = "git::https://github.com/<org-bgh>/terraform-modules-bgh.git//modules/vpc?ref=v1.0.0"

  name                = "${var.cliente}-networking"
  cidr_block          = var.vpc_cidr
  azs                 = var.azs
  public_subnet_cidrs = var.public_subnet_cidrs
  tgw_subnet_cidrs    = var.tgw_subnet_cidrs
  enable_nat          = true
  # Sin private_subnet_cidrs: esta VPC no aloja recursos propios por default. El NAT sirve
  # al tráfico de la subnet de TGW attachment (ruta agregada más abajo), no a una subnet
  # privada — si en el futuro hace falta alojar algo acá (ej. DNS central), agregar
  # private_subnet_cidrs de vuelta.
}

module "tgw_attachment" {
  source = "git::https://github.com/<org-bgh>/terraform-modules-bgh.git//modules/tgw-attachment?ref=v1.0.0"

  name               = "${var.cliente}-networking-attach"
  transit_gateway_id = module.transit_gateway.transit_gateway_id
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.tgw_subnet_ids

  route_table_association_id = module.transit_gateway.route_table_id
  # No propaga nada: el attachment de Networking no es destino final de tráfico por su propio
  # CIDR, así que no necesita que los demás lo conozcan vía propagación.
}

# Ruta estática: 0.0.0.0/0 -> attachment de Networking, en la route table compartida del TGW.
# Vive acá (no dentro de modules/transit-gateway) para evitar una dependencia circular entre
# el Transit Gateway y su propio attachment — ver transit-gateway/README.md.
resource "aws_ec2_transit_gateway_route" "default_to_networking" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_route_table_id = module.transit_gateway.route_table_id
  transit_gateway_attachment_id  = module.tgw_attachment.attachment_id
}

# Ruta default de la subnet de TGW de esta VPC: todo lo que llega del Transit Gateway sin
# coincidir con nada más específico (osea, tráfico realmente destinado a Internet, porque el
# tráfico Prod<->Dev nunca entra acá — viaja directo por el Transit Gateway) sale por el NAT
# Gateway de esta misma VPC. Asume mismo orden/cantidad de AZs entre public_subnet_cidrs y
# tgw_subnet_cidrs.
resource "aws_route" "tgw_subnet_default_to_nat" {
  count                  = length(var.tgw_subnet_cidrs)
  route_table_id         = module.vpc.tgw_route_table_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = module.vpc.nat_gateway_ids[count.index]
}
