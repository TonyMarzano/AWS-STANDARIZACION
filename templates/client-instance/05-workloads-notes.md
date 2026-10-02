# Notas de workloads (Terraform) — [NOMBRE DEL CLIENTE]

> Se completa en la Etapa 3. Ver [`docs/03-workloads/README.md`](../../docs/03-workloads/README.md).

## Backend de state

| Campo | Valor |
|---|---|
| Repo Terraform | `tf-<cliente>` |
| Bucket de state | `tf-state-<cliente>` |
| Tabla de locks | `tf-locks-<cliente>` |
| Cuenta Shared Services (Account ID) | |
| Región | |

## Red de referencia (Transit Gateway + egress centralizado)

Ver [`docs/03-workloads/05-arquitectura-red-referencia.md`](../../docs/03-workloads/05-arquitectura-red-referencia.md).

| Campo | Valor |
|---|---|
| Cuenta Networking (Account ID) | |
| CIDR VPC Networking | |
| CIDR VPC Workloads Prod | |
| CIDR VPC Workloads Dev | |
| Transit Gateway ID | |
| Fecha primer `apply` exitoso de `envs/networking/network` | |

## Workloads

| Workload | Ambiente | Componente (`envs/<env>/<workload>/`) | Cuenta | Notas |
|---|---|---|---|---|
| network | networking | `envs/networking/network` | | Transit Gateway + VPC de Networking (NAT) — desplegar primero |
| network | prod | `envs/prod/network` | | |
| network | nonprod | `envs/nonprod/network` | | Cuenta Workloads Dev |
| | | | | |

## Checklist de cierre de etapa

- [ ] Backend de state bootstrapeado (bucket + tabla, versionado/cifrado activo)
- [ ] `envs/networking/network` desplegado; ambas cuentas spoke aceptaron la invitación de RAM del Transit Gateway
- [ ] `envs/prod/network` y `envs/nonprod/network` desplegados y attachados, asociados a la route table compartida
- [ ] Validación de ruteo (Prod↔Dev directo, salida a Internet vía Networking) — ver checklist en `05-arquitectura-red-referencia.md`
- [ ] Cada workload nuevo documentado en la tabla de arriba
- [ ] Tags obligatorios verificados contra la Tag Policy de la Etapa 2
