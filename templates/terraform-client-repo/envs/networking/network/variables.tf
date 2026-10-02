variable "cliente" {
  description = "Nombre corto del cliente, usado en tags y naming"
  type        = string
}

variable "region" {
  description = "Región AWS de este ambiente (debe coincidir con la home region de la Etapa 1)"
  type        = string
}

variable "aws_profile" {
  description = "Profile de AWS CLI para la cuenta Networking del cliente"
  type        = string
}

variable "azs" {
  description = "Availability Zones a usar (al menos 2, por alta disponibilidad)"
  type        = list(string)
}

variable "vpc_cidr" {
  description = "CIDR de la VPC de Networking (definido en el intake de la Etapa 1)"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Un CIDR de subnet pública por AZ — IGW + NAT Gateway para la salida centralizada a Internet de toda la Organization"
  type        = list(string)
}

variable "tgw_subnet_cidrs" {
  description = "Un CIDR de subnet de attachment al Transit Gateway por AZ"
  type        = list(string)
}

variable "spoke_account_ids" {
  description = "Account IDs de las cuentas spoke (Workloads Prod, Workloads Dev) con las que se comparte el Transit Gateway vía RAM"
  type        = list(string)
}
