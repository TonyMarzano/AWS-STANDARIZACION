variable "cliente" {
  description = "Nombre corto del cliente, usado en tags y naming"
  type        = string
}

variable "region" {
  description = "Región de despliegue (home region de Control Tower)."
  type        = string
  default     = "sa-east-1"
}

variable "account_ids" {
  description = "Account IDs de las cuentas destino."
  type = object({
    network = string
    shared  = string
    prod    = string
    qa      = string
  })

  validation {
    condition     = alltrue([for id in values(var.account_ids) : can(regex("^[0-9]{12}$", id))])
    error_message = "Todos los account IDs deben tener 12 dígitos."
  }
}

variable "assume_role_name" {
  description = "Rol con permisos de administración a asumir en cada cuenta destino."
  type        = string
  default     = "AWSControlTowerExecution"
}

variable "supernet_cidr" {
  description = "Rango total de AWS del cliente. Se usa para las rutas de retorno de la VPC de Networking hacia el TGW."
  type        = string
  default     = "10.105.0.0/16"
}

variable "amazon_side_asn" {
  description = "ASN del lado AWS del Transit Gateway."
  type        = number
  default     = 64512
}

variable "manage_ram_org_sharing" {
  description = "Si es true, habilita RAM sharing con la Organization desde Management. Dejar en false si LZA/Control Tower ya lo habilitó (se puede chequear con `aws ram get-resource-shares`/consola RAM > Settings)."
  type        = bool
  default     = false
}

variable "fortigate_lan_eni_ids" {
  description = <<-EOT
    ENI de la interfaz LAN del FortiGate por AZ (claves az1/az2). Si se define, se crea en la subnet
    attachment-tg de esa AZ la ruta 0.0.0.0/0 hacia la ENI (inspección del tráfico que entra desde el TGW).
    Vacío mientras no estén desplegados los FortiGate.
  EOT
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for k in keys(var.fortigate_lan_eni_ids) : contains(["az1", "az2"], k)])
    error_message = "Las claves válidas son az1 y az2."
  }
}

variable "tags" {
  description = "Tags adicionales (CostCenter, Owner, etc.)."
  type        = map(string)
  default     = {}
}
