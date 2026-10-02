# Componente "network": VPC del ambiente + attachment al Transit Gateway central.
# Todos los demás componentes (workloads) leen los outputs de este state vía terraform_remote_state.
#
# Requiere que envs/networking/network ya esté desplegado y que esta cuenta haya aceptado la
# invitación de RAM del Transit Gateway (ver docs/03-workloads/05-arquitectura-red-referencia.md).
# Esta VPC NO tiene salida propia a Internet (sin public_subnet_cidrs/NAT): la salida a Internet
# de toda la Organization se centraliza en la VPC de la cuenta Networking. El tráfico hacia otro
# spoke (ej. Dev) viaja directo por el Transit Gateway, sin pasar por Networking.
#
# Los módulos "vpc" y "tgw-attachment" viven en el repo terraform-modules-bgh (todavía no creado
# al momento de escribir este skeleton — ver docs/03-workloads/03-modulos-reutilizables.md).
# Reemplazar el "source" de abajo por la referencia real con ?ref=vX.Y.Z una vez exista el módulo.

module "vpc" {
  source = "git::https://github.com/<org-bgh>/terraform-modules-bgh.git//modules/vpc?ref=v1.0.0"

  name                 = "${var.cliente}-workloads-prod"
  cidr_block           = var.vpc_cidr
  azs                  = var.azs
  private_subnet_cidrs = var.private_subnet_cidrs
  tgw_subnet_cidrs     = var.tgw_subnet_cidrs
}

module "tgw_attachment" {
  source = "git::https://github.com/<org-bgh>/terraform-modules-bgh.git//modules/tgw-attachment?ref=v1.0.0"

  name               = "${var.cliente}-workloads-prod-attach"
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.tgw_subnet_ids

  route_table_association_id  = var.tgw_route_table_id
  route_table_propagation_ids = [var.tgw_route_table_id]
}
