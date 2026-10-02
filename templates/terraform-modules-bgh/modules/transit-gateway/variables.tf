variable "name" {
  description = "Nombre base del Transit Gateway y recursos asociados"
  type        = string
}

variable "amazon_side_asn" {
  description = "ASN del lado de Amazon para el Transit Gateway"
  type        = number
  default     = 64512
}

variable "spoke_account_ids" {
  description = "Account IDs de las cuentas spoke (Workloads Prod, Workloads Dev, etc.) con las que se comparte el Transit Gateway vía AWS RAM. Cada cuenta debe aceptar la invitación de recurso compartido antes de poder crear su attachment."
  type        = list(string)
}
