variable "name" {
  description = "Nombre para tags del attachment"
  type        = string
}

variable "transit_gateway_id" {
  description = "ID del Transit Gateway central (output de modules/transit-gateway)"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC a attachear"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets dedicadas al attachment, una por AZ (output tgw_subnet_ids del módulo vpc)"
  type        = list(string)
}

variable "appliance_mode_support" {
  description = "Dejar en \"disable\" (default) para una VPC spoke o la VPC de Networking de la arquitectura de referencia estándar. Solo tiene sentido en \"enable\" si en el futuro se agrega un appliance de red stateful detrás del attachment (fija cada flujo/5-tuple a un mismo ENI del attachment)."
  type        = string
  default     = "disable"
}

variable "route_table_association_id" {
  description = "ID de la TGW route table a la que se asocia este attachment (output route_table_id del módulo transit-gateway)"
  type        = string
}

variable "route_table_propagation_ids" {
  description = "IDs de TGW route tables donde este attachment propaga el CIDR de su VPC. Cada spoke propaga hacia la route table central para que su CIDR sea alcanzable por los demás attachments. El attachment de la VPC de Networking no necesita propagar nada (no es el destino final de ningún tráfico por su propio CIDR)."
  type        = list(string)
  default     = []
}
