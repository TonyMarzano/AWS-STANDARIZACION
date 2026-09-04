# Estructura de repos

## Por qué un repo por cliente

Mismo criterio que ya aplicamos en las Etapas 1 y 2: mezclar Terraform de varios clientes en un monorepo mezcla también sus permisos de acceso, su blast radius, y su confidencialidad (CIDRs, IPs, nombres de recursos internos). Un repo por cliente permite, además, darle acceso de lectura al propio cliente sobre su infraestructura como código si el contrato lo prevé, sin exponer a nadie más.

No usamos un repo por workload porque multiplicaría la cantidad de repos a mantener sin necesidad real la mayoría de las veces — el aislamiento entre workloads de un mismo cliente ya lo da tener **state files separados** (ver [`02-backend-state.md`](02-backend-state.md)), no hace falta separar también el repo.

## Convención de nombres

- Repo: `tf-<cliente>` (ej. `tf-acme-corp`), privado, bajo la org/cuenta de GitHub que se defina para repos de clientes.
- Dentro del repo, cada **componente** (unidad desplegable con su propio state) vive en `envs/<ambiente>/<componente>/`.

## Layout

```
tf-<cliente>/
├── README.md                       Qué hay en este repo, cómo correrlo, a qué Organization pertenece
├── .gitignore                      Ignora .terraform/, *.tfstate*, *.tfvars con secretos
├── envs/
│   ├── prod/
│   │   ├── network/                 VPC del ambiente + attachment al Transit Gateway central (LZA)
│   │   │   ├── main.tf
│   │   │   ├── backend.tf
│   │   │   ├── variables.tf
│   │   │   ├── providers.tf
│   │   │   └── terraform.tfvars
│   │   ├── <workload-a>/            Ej: "ecommerce" — ALB, ASG/EC2, security groups propios
│   │   │   └── (mismo set de archivos)
│   │   └── <workload-b>/
│   └── nonprod/
│       └── (mismo patrón que prod, con sus propios .tfvars y su propio state)
```

## Por qué separar `network/` del resto

El componente `network` (VPC del ambiente + attachment a TGW) es la base de la que dependen todos los workloads de ese ambiente. Separarlo en su propio state evita que un `terraform apply` de un workload puntual pueda tocar por error la red compartida del ambiente, y permite que un solo cambio de red no obligue a re-plan todos los workloads. Los workloads consumen los outputs de `network` vía `terraform_remote_state` (ver [`02-backend-state.md`](02-backend-state.md)), nunca duplicando valores a mano.

## Qué NO va en Terraform acá

Todo lo que ya gestiona LZA en la Etapa 2 (guardrails, SCPs, estructura de OUs, Transit Gateway central, IPAM) **no se toca desde Terraform de workloads**. Este repo consume esos recursos (ej. el TGW ya existe, acá solo se hace el attachment desde el lado del workload), nunca los redefine. Redefinir algo que ya gestiona LZA genera drift y conflictos entre las dos herramientas.

## Siguiente paso

[`02-backend-state.md`](02-backend-state.md)
