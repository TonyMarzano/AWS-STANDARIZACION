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

## Workloads

| Workload | Ambiente | Componente (`envs/<env>/<workload>/`) | Cuenta | Notas |
|---|---|---|---|---|
| network | prod | `envs/prod/network` | | |
| network | nonprod | `envs/nonprod/network` | | |
| | | | | |

## Checklist de cierre de etapa

- [ ] Backend de state bootstrapeado (bucket + tabla, versionado/cifrado activo)
- [ ] `envs/prod/network` y `envs/nonprod/network` desplegados y attachados al Transit Gateway central
- [ ] Cada workload nuevo documentado en la tabla de arriba
- [ ] Tags obligatorios verificados contra la Tag Policy de la Etapa 2
