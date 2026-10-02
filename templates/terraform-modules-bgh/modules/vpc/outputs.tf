output "vpc_id" {
  value = aws_vpc.this.id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "private_route_table_ids" {
  value = aws_route_table.private[*].id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "public_route_table_ids" {
  value = aws_route_table.public[*].id
}

output "nat_gateway_ids" {
  description = "Vacío si enable_nat = false. Un NAT Gateway por subnet pública, mismo orden que var.azs."
  value       = aws_nat_gateway.this[*].id
}

output "tgw_subnet_ids" {
  value = aws_subnet.tgw[*].id
}

output "tgw_route_table_ids" {
  value = aws_route_table.tgw[*].id
}
