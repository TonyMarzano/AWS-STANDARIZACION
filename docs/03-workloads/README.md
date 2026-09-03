# Etapa 3 — Workloads

> **Estado: pendiente de completar en detalle.** Se desarrolla cuando definamos la estructura estándar de Terraform a usar entre clientes.

## Punto de partida

Con las cuentas de la Etapa 2 ya creadas (Prod, NonProd, Shared Services, etc.) y la red base (Transit Gateway/IPAM) desplegada por LZA, acá se construye por Terraform lo específico de cada carga de trabajo:

- VPC de la carga de trabajo (attachment al Transit Gateway central).
- Subredes, route tables, security groups.
- Balanceadores (ALB/NLB).
- Cómputo (EC2, ASG, ECS/EKS según el caso).
- Cualquier otro recurso de aplicación.

## Pendiente de documentar acá

- [ ] Estructura estándar de repos/módulos Terraform (¿un repo por cliente? ¿módulos reusables versionados en un registry propio?).
- [ ] Backend de state (S3 + DynamoDB por cliente, ¿centralizado en qué cuenta?).
- [ ] Convención de naming y tagging (heredada del intake, reforzada acá).
- [ ] Pipeline de CI/CD para aplicar Terraform (si aplica).

## Etapas previas

- [Etapa 1 — Onboarding](../01-onboarding/README.md)
- [Etapa 2 — Landing Zone Accelerator](../02-landing-zone-accelerator/README.md)
