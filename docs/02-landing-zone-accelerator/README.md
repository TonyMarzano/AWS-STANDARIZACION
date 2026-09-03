# Etapa 2 — Landing Zone Accelerator (LZA)

> **Estado: pendiente de completar en detalle.** Este documento es un stub — lo desarrollamos a fondo (instalación paso a paso + mapeo de cada campo del intake a los YAML de config) en la próxima sesión de trabajo sobre esta etapa.

## Referencia oficial

https://awslabs.github.io/landing-zone-accelerator-on-aws/latest/

## Qué resuelve

LZA toma la Organization con Control Tower ya desplegado (Etapa 1) y aplica, vía configuración declarativa + pipeline propio (CodePipeline/CodeBuild + CDK), el resto de la Landing Zone:

- Estructura completa de OUs y cuentas (`accounts-config.yaml`, `organization-config.yaml`).
- Guardrails de seguridad y SCPs (`security-config.yaml`).
- Red centralizada — Transit Gateway, IPAM, VPCs compartidas si aplica (`network-config.yaml`).
- Roles y permission sets de IAM Identity Center (`iam-config.yaml`).
- Configuración global de logging/regiones (`global-config.yaml`).
- Customizaciones puntuales (`customizations-config.yaml`).

## Pendiente de documentar acá

- [ ] Guía de instalación del pipeline de LZA en la cuenta management.
- [ ] Tabla de mapeo: campo del intake (`templates/client-intake-form.md`) → archivo/clave de config de LZA.
- [ ] Checklist de validación post-despliegue.
- [ ] Notas de troubleshooting comunes (drift, fallos de pipeline, límites de servicio).

## Siguiente etapa

[`docs/03-workloads/README.md`](../03-workloads/README.md)
