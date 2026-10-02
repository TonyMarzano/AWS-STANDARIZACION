# terraform-modules-bgh (skeleton)

> Esto es el **punto de partida** para el repo real `terraform-modules-bgh`, descrito en [`docs/03-workloads/03-modulos-reutilizables.md`](../../docs/03-workloads/03-modulos-reutilizables.md). Cuando se cree el repo real, copiar este contenido como primer commit y empezar a versionar por tag desde ahí (`v1.0.0`).

## Módulos disponibles

| Módulo | Para qué sirve | Se usa en |
|---|---|---|
| [`vpc`](modules/vpc/) | VPC genérica: subnets privadas + públicas/NAT opcionales + subnet de attachment al Transit Gateway opcional | Las tres cuentas: Networking, Workloads Prod, Workloads Dev |
| [`transit-gateway`](modules/transit-gateway/) | Transit Gateway central + route table compartida + RAM share a las cuentas spoke | Cuenta Networking, una sola vez |
| [`tgw-attachment`](modules/tgw-attachment/) | Attachment de una VPC al Transit Gateway, con asociación/propagación explícita a route tables | Toda VPC que se conecte al Transit Gateway |

Juntos implementan la **arquitectura de red de referencia con egress centralizado** documentada en [`docs/03-workloads/05-arquitectura-red-referencia.md`](../../docs/03-workloads/05-arquitectura-red-referencia.md) — leer ese documento antes de tocar estos módulos, tiene el diagrama y la explicación de por qué el ruteo está diseñado así.

## Versionado

Semver por tag de git (`v1.0.0`, `v1.1.0`, ...). Ver el criterio completo en `03-modulos-reutilizables.md`.
