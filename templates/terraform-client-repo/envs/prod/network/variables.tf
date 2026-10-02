variable "cliente" {
  description = "Nombre corto del cliente, usado en tags y naming"
  type        = string
}

variable "region" {
  description = "Región AWS de este ambiente (debe coincidir con la home region de la Etapa 1)"
  type        = string
}

variable "aws_profile" {
  description = "Profile de AWS CLI para la cuenta Prod del cliente"
  type        = string
}

variable "azs" {
  description = "Availability Zones a usar, mismas que en la VPC de Networking (al menos 2)"
  type        = list(string)
}

variable "vpc_cidr" {
  description = "CIDR de la VPC de este ambiente (definido en el intake de la Etapa 1)"
  type        = string
}

variable "private_subnet_cidrs" {
  description = "Un CIDR de subnet privada por AZ"
  type        = list(string)
}

variable "tgw_subnet_cidrs" {
  description = "Un CIDR de subnet de attachment al Transit Gateway por AZ"
  type        = list(string)
}

variable "transit_gateway_id" {
  description = "ID del Transit Gateway central (output de envs/networking/network — esta cuenta debe haber aceptado antes la invitación de RAM, ver docs/03-workloads/05-arquitectura-red-referencia.md)"
  type        = string
}

variable "tgw_route_table_id" {
  description = "ID de la route table compartida del Transit Gateway (output tgw_route_table_id de envs/networking/network) — este attachment se asocia y propaga ahí"
  type        = string
}
