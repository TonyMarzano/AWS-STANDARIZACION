# Se ejecuta con credenciales de la cuenta Management (perfil SSO <cliente>-mgmt) y se asume un rol
# de administración en cada cuenta destino. AWSControlTowerExecution existe en toda cuenta enrolada
# por Control Tower/LZA y confía en la cuenta Management.

locals {
  default_tags = merge({
    Cliente   = var.cliente
    ManagedBy = "Terraform"
    Stack     = "networking"
  }, var.tags)

  role_arn = { for k, id in var.account_ids : k => "arn:aws:iam::${id}:role/${var.assume_role_name}" }
}

# Management: solo para RAM sharing con la Organization
provider "aws" {
  region = var.region

  default_tags {
    tags = local.default_tags
  }
}

provider "aws" {
  alias  = "network"
  region = var.region

  assume_role {
    role_arn = local.role_arn["network"]
  }

  default_tags {
    tags = local.default_tags
  }
}

provider "aws" {
  alias  = "shared"
  region = var.region

  assume_role {
    role_arn = local.role_arn["shared"]
  }

  default_tags {
    tags = local.default_tags
  }
}

provider "aws" {
  alias  = "prod"
  region = var.region

  assume_role {
    role_arn = local.role_arn["prod"]
  }

  default_tags {
    tags = local.default_tags
  }
}

provider "aws" {
  alias  = "qa"
  region = var.region

  assume_role {
    role_arn = local.role_arn["qa"]
  }

  default_tags {
    tags = local.default_tags
  }
}
