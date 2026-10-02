output "transit_gateway_id" {
  value = aws_ec2_transit_gateway.this.id
}

output "transit_gateway_route_table_ids" {
  value = {
    spokes     = aws_ec2_transit_gateway_route_table.spokes.id
    inspection = aws_ec2_transit_gateway_route_table.inspection.id
  }
}

output "vpc_ids" {
  value = {
    networking     = module.vpc_networking.vpc_id
    shared         = module.vpc_shared.vpc_id
    workloads_prod = module.vpc_workloads_prod.vpc_id
    workloads_qa   = module.vpc_workloads_qa.vpc_id
  }
}

output "subnet_ids" {
  value = {
    networking     = module.vpc_networking.subnet_ids
    shared         = module.vpc_shared.subnet_ids
    workloads_prod = module.vpc_workloads_prod.subnet_ids
    workloads_qa   = module.vpc_workloads_qa.subnet_ids
  }
}

output "transit_gateway_attachment_ids" {
  value = merge({ networking = module.vpc_networking.transit_gateway_attachment_id }, local.spoke_attachment_ids)
}
