# Un bloque por cuenta: cada uno usa su propio provider (assume role en la cuenta destino).
# Los spokes dependen de que el TGW ya esté compartido por RAM con la Organization.

module "vpc_networking" {
  source    = "./modules/vpc"
  providers = { aws = aws.network }

  name    = local.vpcs.networking.name
  cidr    = local.vpcs.networking.cidr
  subnets = local.subnets.networking
  tiers   = local.vpcs.networking.tiers

  create_internet_gateway   = true
  attach_to_transit_gateway = true
  transit_gateway_id        = aws_ec2_transit_gateway.this.id
  appliance_mode            = true # simetría de flujos entre AZ a través del FortiGate

  eni_routes = {
    for az, eni in var.fortigate_lan_eni_ids : "${az}_attachment|0.0.0.0/0" => {
      subnet_key           = "${az}_attachment"
      cidr                 = "0.0.0.0/0"
      network_interface_id = eni
    }
  }
}

module "vpc_shared" {
  source    = "./modules/vpc"
  providers = { aws = aws.shared }

  name    = local.vpcs.shared.name
  cidr    = local.vpcs.shared.cidr
  subnets = local.subnets.shared
  tiers   = local.vpcs.shared.tiers

  attach_to_transit_gateway = true
  transit_gateway_id        = aws_ec2_transit_gateway.this.id

  depends_on = [time_sleep.ram_propagation]
}

module "vpc_workloads_prod" {
  source    = "./modules/vpc"
  providers = { aws = aws.prod }

  name    = local.vpcs.workloads_prod.name
  cidr    = local.vpcs.workloads_prod.cidr
  subnets = local.subnets.workloads_prod
  tiers   = local.vpcs.workloads_prod.tiers

  attach_to_transit_gateway = true
  transit_gateway_id        = aws_ec2_transit_gateway.this.id

  depends_on = [time_sleep.ram_propagation]
}

module "vpc_workloads_qa" {
  source    = "./modules/vpc"
  providers = { aws = aws.qa }

  name    = local.vpcs.workloads_qa.name
  cidr    = local.vpcs.workloads_qa.cidr
  subnets = local.subnets.workloads_qa
  tiers   = local.vpcs.workloads_qa.tiers

  attach_to_transit_gateway = true
  transit_gateway_id        = aws_ec2_transit_gateway.this.id

  depends_on = [time_sleep.ram_propagation]
}
