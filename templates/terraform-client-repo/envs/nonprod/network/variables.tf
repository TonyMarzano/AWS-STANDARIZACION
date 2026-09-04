variable "cliente" {
  description = "Nombre corto del cliente, usado en tags y naming"
  type        = string
}

variable "region" {
  description = "Región AWS de este ambiente (debe coincidir con la home region de la Etapa 1)"
  type        = string
}

variable "aws_profile" {
  description = "Profile de AWS CLI para la cuenta NonProd del cliente"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR de la VPC de este ambiente (definido en el intake de la Etapa 1)"
  type        = string
}

variable "transit_gateway_id" {
  description = "ID del Transit Gateway central desplegado por LZA en la Etapa 2"
  type        = string
}
