# Etapa 3 — Workloads

Checklist maestro de la etapa. Cada paso linkea al detalle.

## Punto de partida

Con las cuentas de la Etapa 2 ya creadas (Prod, NonProd, Shared Services, etc.) y la red base (Transit Gateway/IPAM) desplegada por LZA, acá se construye por Terraform lo específico de cada carga de trabajo: VPC del workload y su attachment al Transit Gateway central, subredes, security groups, balanceadores, cómputo, y cualquier otro recurso de aplicación.

## Decisiones de arquitectura (fijas para todos los clientes)

| Decisión | Elegido |
|---|---|
| Estructura de repos | Un repo de Terraform por cliente (`tf-<cliente>`) |
| Backend de state | S3 + DynamoDB en la cuenta **Shared Services** del propio cliente (no centralizado en BGH) |
| Reutilización de módulos | Repo aparte `terraform-modules-bgh`, módulos versionados por tag (`?ref=vX.Y.Z`) |
| Separación de ambientes | Carpetas y state separados por ambiente (`envs/prod/`, `envs/nonprod/`), no Workspaces |

Detalle y justificación de cada una en los documentos de esta carpeta.

## Flujo

1. [ ] **Estructura del repo** del cliente → [`01-estructura-repos.md`](01-estructura-repos.md)
2. [ ] **Bootstrap del backend de state** (S3 + DynamoDB en Shared Services) → [`02-backend-state.md`](02-backend-state.md)
3. [ ] **Módulos reutilizables** — cómo referenciarlos y cómo versionarlos → [`03-modulos-reutilizables.md`](03-modulos-reutilizables.md)
4. [ ] **Flujo de trabajo** día a día (plan/review/apply, tagging, CI/CD) → [`04-flujo-trabajo.md`](04-flujo-trabajo.md)
5. [ ] Registrar todo en `05-workloads-notes.md` del repo de instancia del cliente

## Skeleton para arrancar

[`templates/terraform-client-repo/`](../../templates/terraform-client-repo/) — copiar como raíz del repo nuevo `tf-<cliente>`.

## Etapas previas

- [Etapa 1 — Onboarding](../01-onboarding/README.md)
- [Etapa 2 — Landing Zone Accelerator](../02-landing-zone-accelerator/README.md)
