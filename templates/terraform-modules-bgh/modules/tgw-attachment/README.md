# Módulo `tgw-attachment`

Attachea una VPC al Transit Gateway central, con asociación y propagación explícitas a route tables del TGW (nunca a la default). Se usa tanto para las VPCs spoke como para la VPC de Networking.

## Uso — attachment de un spoke (Workloads Prod/Dev)

```hcl
module "tgw_attachment" {
  source = "git::https://github.com/<org-bgh>/terraform-modules-bgh.git//modules/tgw-attachment?ref=v1.0.0"

  name               = "cliente-workloads-prod-attach"
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.tgw_subnet_ids

  route_table_association_id  = var.tgw_route_table_id
  route_table_propagation_ids = [var.tgw_route_table_id]
}
```

## Uso — attachment de la VPC de Networking

```hcl
module "tgw_attachment" {
  source = "git::https://github.com/<org-bgh>/terraform-modules-bgh.git//modules/tgw-attachment?ref=v1.0.0"

  name               = "cliente-networking-attach"
  transit_gateway_id = module.transit_gateway.transit_gateway_id
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.tgw_subnet_ids

  route_table_association_id = module.transit_gateway.route_table_id
  # No propaga nada: la ruta default hacia este attachment se agrega aparte,
  # como ruta estática — ver envs/networking/network/main.tf.
}
```
