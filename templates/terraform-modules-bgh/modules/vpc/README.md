# Módulo `vpc`

VPC genérica con subnets privadas, públicas (opcional) y de attachment al Transit Gateway (opcional), una por AZ. Se usa para **las tres VPCs** de la arquitectura de referencia: Networking, Workloads Prod y Workloads Dev.

## Uso típico — VPC spoke (sin salida propia a Internet)

```hcl
module "vpc" {
  source = "git::https://github.com/<org-bgh>/terraform-modules-bgh.git//modules/vpc?ref=v1.0.0"

  name                  = "cliente-workloads-prod"
  cidr_block            = "10.1.0.0/16"
  azs                   = ["us-east-1a", "us-east-1b"]
  private_subnet_cidrs  = ["10.1.0.0/20", "10.1.16.0/20"]
  tgw_subnet_cidrs      = ["10.1.252.0/28", "10.1.252.16/28"]
  # public_subnet_cidrs y enable_nat quedan en default (sin salida propia):
  # la salida a Internet de toda la Organization se centraliza en la VPC de Networking.
}
```

## Uso típico — VPC de Networking (con salida centralizada a Internet)

```hcl
module "vpc" {
  source = "git::https://github.com/<org-bgh>/terraform-modules-bgh.git//modules/vpc?ref=v1.0.0"

  name                 = "cliente-networking"
  cidr_block           = "10.0.0.0/16"
  azs                  = ["us-east-1a", "us-east-1b"]
  private_subnet_cidrs = ["10.0.0.0/20", "10.0.16.0/20"]
  public_subnet_cidrs  = ["10.0.100.0/24", "10.0.101.0/24"]
  tgw_subnet_cidrs     = ["10.0.252.0/28", "10.0.252.16/28"]
  enable_nat           = true
}
```

Ver cómo se conecta todo (route tables del Transit Gateway, ruta default hacia Networking) en [`docs/03-workloads/05-arquitectura-red-referencia.md`](../../../docs/03-workloads/05-arquitectura-red-referencia.md).
