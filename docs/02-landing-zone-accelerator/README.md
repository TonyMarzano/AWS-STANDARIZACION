# Etapa 2 — Landing Zone Accelerator (LZA)

Checklist maestro de la etapa. Cada paso linkea al detalle.

## Referencia oficial

- Guía de usuario: https://awslabs.github.io/landing-zone-accelerator-on-aws/latest/
- Implementation Guide (AWS Solutions): https://docs.aws.amazon.com/solutions/latest/landing-zone-accelerator-on-aws/solution-overview.html
- Código fuente: https://github.com/awslabs/landing-zone-accelerator-on-aws

## Qué resuelve

LZA toma la Organization con Control Tower ya desplegado (Etapa 1) y aplica, vía configuración declarativa + un pipeline propio (CodePipeline + CDK), el resto de la Landing Zone: estructura de OUs y cuentas, guardrails de seguridad, red centralizada, roles/permission sets de identidad, y logging avanzado. AWS lo recomienda explícitamente como complemento de Control Tower, no como reemplazo — por eso en nuestra metodología va **después** de la Etapa 1, nunca antes.

> Aclaración importante de AWS: *"This solution will not, by itself, make you compliant."* LZA da la base técnica; el cumplimiento normativo específico del cliente sigue siendo una responsabilidad nuestra/del cliente sobre esa base.

## Flujo

1. [ ] **Prerrequisitos e instalación** del Installer Stack en la cuenta management → [`01-prerequisitos-e-instalacion.md`](01-prerequisitos-e-instalacion.md)
2. [ ] **Mapeo del relevamiento a los archivos de configuración** (los 7 YAML de LZA) → [`02-mapeo-configuracion.md`](02-mapeo-configuracion.md)
3. [ ] **Despliegue** (commit de la config, pipeline, aprobación manual) **y validación** → [`03-despliegue-y-validacion.md`](03-despliegue-y-validacion.md)
4. [ ] Registrar todo en `04-lza-config-notes.md` del repo de instancia del cliente

## Criterio de salida de la etapa

- El pipeline `AWSAccelerator-Pipeline` corrió exitosamente de punta a punta con la configuración final del cliente (no la de ejemplo).
- Las cuentas de `accounts-config.yaml` existen y están en la OU correcta.
- Guardrails de `security-config.yaml` activos y en estado compliant.
- Red de `network-config.yaml` desplegada (VPCs/TGW/IPAM según lo relevado).
- Permission sets de `iam-config.yaml` asignados y probados con al menos un login de prueba.
- `04-lza-config-notes.md` del cliente completo, sin TBDs.

## Siguiente etapa

[`docs/03-workloads/README.md`](../03-workloads/README.md)
