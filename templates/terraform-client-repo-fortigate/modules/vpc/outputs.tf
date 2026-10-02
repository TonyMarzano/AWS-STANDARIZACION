output "vpc_id" {
  value = aws_vpc.this.id
}

output "subnet_ids" {
  value = { for k, s in aws_subnet.this : k => s.id }
}

output "route_table_ids" {
  value = { for k, rt in aws_route_table.this : k => rt.id }
}

output "transit_gateway_attachment_id" {
  value = try(aws_ec2_transit_gateway_vpc_attachment.this[0].id, null)
}
