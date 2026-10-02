variable "name" {
  description = "Nombre base para tags/Name de los recursos de esta VPC"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block de la VPC"
  type        = string
}

variable "azs" {
  description = "Availability Zones a usar, una entrada por AZ (ej. [\"us-east-1a\", \"us-east-1b\"])"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Un CIDR de subnet privada por AZ, mismo orden que var.azs. Dejar vacío (default) si esta VPC no aloja ningún recurso propio — ej. la VPC de Networking, donde el NAT sirve al tráfico de la subnet de TGW attachment, no a una subnet privada."
  type        = list(string)
  default     = []
}

variable "public_subnet_cidrs" {
  description = "Un CIDR de subnet pública por AZ. Dejar vacío (default) en una VPC spoke — no tienen salida directa a Internet, la salida se centraliza en la VPC de la cuenta Networking."
  type        = list(string)
  default     = []
}

variable "tgw_subnet_cidrs" {
  description = "Un CIDR de subnet dedicada al attachment del Transit Gateway por AZ (best practice de AWS: no reusar subnets de aplicación para el ENI del TGW). Requerido para toda VPC que se conecte al Transit Gateway central."
  type        = list(string)
  default     = []
}

variable "enable_nat" {
  description = "Crear un NAT Gateway por AZ en las subnets públicas, con ruta 0.0.0.0/0 desde las subnets privadas (si las hay). En la arquitectura de referencia esto queda en false para las VPCs spoke — la salida a Internet se centraliza en la VPC de la cuenta Networking. OJO: este módulo NO rutea automáticamente la subnet de TGW attachment hacia el NAT — esa ruta se agrega aparte, en el env que compone el módulo (ver envs/networking/network/main.tf), porque depende de recursos fuera de esta VPC."
  type        = bool
  default     = false
}
