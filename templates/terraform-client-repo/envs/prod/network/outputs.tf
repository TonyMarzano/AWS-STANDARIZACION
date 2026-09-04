# Outputs consumidos por los componentes de workload vía terraform_remote_state.
# Todo lo que un workload vaya a necesitar de la red debe exponerse acá explícitamente.

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}
