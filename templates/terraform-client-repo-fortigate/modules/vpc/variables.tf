variable "name" {
  description = "Nombre de la VPC (vpc_<region>_<...>). Se derivan de acá los nombres del IGW y del attachment."
  type        = string
}

variable "cidr" {
  type = string
}

variable "subnets" {
  description = "Subnets por clave. Cada subnet tiene su propia route table (nombre de la subnet con prefijo subnet_ -> rt_)."
  type = map(object({
    name  = string
    cidr  = string
    az    = string # az1 | az2
    az_id = string # sae1-az1 | sae1-az2
    tier  = string
  }))
}

variable "tiers" {
  description = "Política de ruteo por tier: CIDRs con destino IGW y/o TGW."
  type = map(object({
    igw_cidrs = optional(list(string), [])
    tgw_cidrs = optional(list(string), [])
  }))
}

variable "create_internet_gateway" {
  type    = bool
  default = false
}

variable "attach_to_transit_gateway" {
  description = "Crea el TGW attachment usando las subnets con tier = attachment."
  type        = bool
  default     = false
}

variable "transit_gateway_id" {
  type    = string
  default = null
}

variable "appliance_mode" {
  description = "Appliance mode del attachment (obligatorio en la VPC de inspección para mantener simetría entre AZ)."
  type        = bool
  default     = false
}

variable "eni_routes" {
  description = "Rutas hacia una ENI (ej: FortiGate). Se ignoran las entradas con network_interface_id = null."
  type = map(object({
    subnet_key           = string
    cidr                 = string
    network_interface_id = optional(string)
  }))
  default = {}
}
