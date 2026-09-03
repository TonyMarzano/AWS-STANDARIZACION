# AWS Landing Zone — Metodología de Despliegue (BGH Tech Partner)

Repo **plantilla** para estandarizar el despliegue de AWS Organizations / Landing Zones para clientes nuevos de BGH Tech Partner. No contiene datos de ningún cliente: es la metodología, los checklists, los templates de relevamiento y los scripts genéricos que se reutilizan en cada onboarding.

## Cómo se usa esto

1. Este repo es la **fuente de verdad de la metodología**. Se actualiza cuando aprendemos algo nuevo o cambia una práctica (ej. nueva versión de LZA, cambio de checklist).
2. Para un cliente nuevo, **no se trabaja adentro de este repo**. Se crea un repo nuevo (privado, uno por cliente) a partir de [`templates/client-instance/`](templates/client-instance/), porque ahí sí van a vivir datos sensibles del cliente (CIDRs, IDs de cuenta, emails, configuración SSO). Mezclar clientes en un mismo repo es un riesgo de confidencialidad que evitamos así.
3. El flujo de trabajo completo está en [`docs/00-metodologia.md`](docs/00-metodologia.md).

## Estructura

```
docs/
  00-metodologia.md              Visión general de las 3 etapas, roles, entradas/salidas
  01-onboarding/                 Etapa 1: relevamiento, cuentas, baseline, Control Tower
  02-landing-zone-accelerator/   Etapa 2: despliegue de LZA
  03-workloads/                  Etapa 3: Terraform de cargas de trabajo
templates/
  client-intake-form.md          Formulario de relevamiento para enviar/completar con el cliente
  client-instance/                Skeleton a copiar en el repo nuevo de cada cliente
scripts/
  01-onboarding/                 Scripts PowerShell + AWS CLI para la Etapa 1
```

## Las 3 etapas (resumen)

| Etapa | Qué se hace | Herramienta principal |
|---|---|---|
| 1. Onboarding | Relevamiento, cuenta management, emails, baseline de seguridad (MFA root, budgets, Organizations), Control Tower mínimo | Manual + AWS CLI / PowerShell |
| 2. Landing Zone Accelerator | Despliegue de guardrails, cuentas, red base y compliance vía LZA (CDK gestionado por AWS) | LZA (config YAML) |
| 3. Workloads | VPC, Transit Gateway, servidores, balanceadores, etc. por cliente/carga de trabajo | Terraform |

Detalle completo de cada etapa en `docs/`.
