# Componente "network": VPC del ambiente + attachment al Transit Gateway central (LZA).
# Todos los demás componentes (workloads) leen los outputs de este state vía terraform_remote_state.
#
# Los módulos "vpc" y "tgw-attachment" viven en el repo terraform-modules-bgh (todavía no creado
# al momento de escribir este skeleton — ver docs/03-workloads/03-modulos-reutilizables.md).
# Reemplazar el "source" de abajo por la referencia real con ?ref=vX.Y.Z una vez exista el módulo.

module "vpc" {
  source = "git::https://github.com/<org-bgh>/terraform-modules-bgh.git//modules/vpc?ref=v1.0.0"

  cidr_block = var.vpc_cidr
  name       = "${var.cliente}-prod"
}

module "tgw_attachment" {
  source = "git::https://github.com/<org-bgh>/terraform-modules-bgh.git//modules/tgw-attachment?ref=v1.0.0"

  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids
  transit_gateway_id = var.transit_gateway_id
}
