# Outputs consumidos por envs/prod/network y envs/nonprod/network vía terraform_remote_state.

output "transit_gateway_id" {
  value = module.transit_gateway.transit_gateway_id
}

output "tgw_route_table_id" {
  value = module.transit_gateway.route_table_id
}

output "ram_resource_share_arn" {
  value = module.transit_gateway.ram_resource_share_arn
}

output "networking_vpc_id" {
  value = module.vpc.vpc_id
}
