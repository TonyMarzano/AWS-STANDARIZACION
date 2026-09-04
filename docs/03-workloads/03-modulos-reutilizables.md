# Módulos reutilizables

## Por qué un repo aparte, versionado por tag

Los componentes de red y compute se repiten con variaciones menores entre clientes (una VPC es una VPC, un ALB es un ALB). Mantenerlos como módulos versionados en un repo propio (`terraform-modules-bgh`, separado de los repos `tf-<cliente>`) permite:

- Mejorar un módulo una sola vez y que cada cliente decida cuándo actualizar a la nueva versión (no rompe a nadie de forma involuntaria).
- Tener un solo lugar donde se revisan buenas prácticas de Terraform, en vez de N copias divergiendo con el tiempo.

> **Nota:** este repo (`terraform-modules-bgh`) todavía no existe — se crea cuando arranque el Terraform del primer cliente real, con el primer módulo que se necesite (probablemente `network`/VPC). No tiene sentido diseñar módulos genéricos antes de tener un caso real que los valide.

## Estructura esperada de `terraform-modules-bgh`

```
terraform-modules-bgh/
├── README.md                 Índice de módulos disponibles y su versión estable actual
├── modules/
│   ├── vpc/                  VPC + subnets + route tables, parametrizable por CIDR/AZs
│   ├── tgw-attachment/       Attachment de una VPC al Transit Gateway central de LZA
│   ├── alb/                  Application Load Balancer + target groups
│   ├── ec2-asg/              Auto Scaling Group + Launch Template
│   └── .../                  Se agregan a medida que aparece la necesidad real
└── CHANGELOG.md              Un renglón por versión: qué cambió y por qué
```

Cada módulo sigue el layout estándar de Terraform (`main.tf`, `variables.tf`, `outputs.tf`, `README.md` con ejemplo de uso).

## Versionado

- Semver por tag de git: `v1.0.0`, `v1.1.0`, etc. Un cambio breaking (renombra una variable, cambia un output) sube el major.
- Antes de taggear una nueva versión: correr `terraform plan` contra al menos un cliente real (o un ambiente sandbox) para confirmar que no hay drift inesperado.

## Cómo se referencia desde un repo de cliente

```hcl
module "network" {
  source = "git::https://github.com/<org-bgh>/terraform-modules-bgh.git//modules/vpc?ref=v1.2.0"

  cidr_block = "10.0.0.0/16"
  # resto de variables del módulo...
}
```

**Nunca** referenciar sin `?ref=`, ni con una branch (ej. `main`) — eso rompe la reproducibilidad: un `terraform apply` de hoy y uno de dentro de 6 meses deben producir el mismo resultado si el código de `tf-<cliente>` no cambió.

## Actualizar un cliente a una versión nueva del módulo

1. Leer el `CHANGELOG.md` del repo de módulos para ver qué cambió.
2. Cambiar el `?ref=` en el repo del cliente, en una branch aparte.
3. Correr `terraform plan` y revisar el diff con atención — un bump de módulo puede mostrar cambios no triviales.
4. Aplicar solo después de revisar el plan, nunca a ciegas.

## Siguiente paso

[`04-flujo-trabajo.md`](04-flujo-trabajo.md)
