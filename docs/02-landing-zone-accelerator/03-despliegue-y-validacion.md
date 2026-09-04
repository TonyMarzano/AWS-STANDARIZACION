# Despliegue y validación

## 1. Disparar el despliegue

El pipeline `AWSAccelerator-Pipeline` (CodePipeline, cuenta management) se dispara con cada commit a la branch configurada del repo CodeCommit `aws-accelerator-config`. No hay un botón de "deploy" separado: **el commit es el deploy**.

1. Commitear los 7 archivos de configuración ya completados (según [`02-mapeo-configuracion.md`](02-mapeo-configuracion.md)) a la branch del repo de configuración.
2. El pipeline arranca automáticamente. Fases generales (el detalle exacto de nombres de stage puede variar entre versiones de LZA — confirmar en la consola de CodePipeline de la instalación real):
   - Build/síntesis de CDK a partir de la config.
   - Bootstrap de las cuentas involucradas (si es la primera vez).
   - Despliegue de stacks en un orden que respeta dependencias (organización y logging antes que red, red antes que recursos que dependen de ella, etc.).
3. Si se habilitó `EnableApprovalStage=Yes` en la instalación, el pipeline **se detiene antes de aplicar cambios** y envía un email a `ApprovalStageNotifyEmailList`. Revisar el plan de cambios antes de aprobar manualmente en la consola de CodePipeline.

## 2. Seguimiento

- Consola de **CodePipeline** en la cuenta management → ver el estado de cada stage en tiempo real.
- Si un stage falla, el error casi siempre está en el stack de **CloudFormation** correspondiente (nombre con prefijo `AWSAccelerator-`) en la cuenta/región afectada — revisar el tab "Events" de ese stack primero.
- Errores típicos: emails de cuenta que no matchean lo ya existente en Organizations, CIDRs solapados entre VPCs, cuotas de servicio superadas (ej. límite de VPCs por región), permission sets referenciando un grupo que no existe todavía en el IdP.

## 3. Validación post-despliegue

- [ ] El pipeline terminó en estado `Succeeded` de punta a punta.
- [ ] `aws organizations list-accounts` muestra todas las cuentas de `accounts-config.yaml`, en la OU esperada (`aws organizations list-accounts-for-parent`).
- [ ] Los guardrails/Config Rules de `security-config.yaml` aparecen activos y compliant en AWS Config / Security Hub.
- [ ] Los recursos de red de `network-config.yaml` existen (VPCs, Transit Gateway attachments) y los CIDRs son los relevados — sin solapamientos.
- [ ] Los permission sets de `iam-config.yaml` están asignados; hacer **al menos un login de prueba** por perfil relevante (admin, read-only) para confirmar que el acceso funciona de punta a punta, no solo que el recurso "existe".
- [ ] Si se definieron tags obligatorios, crear un recurso de prueba sin el tag y confirmar que la Tag Policy/SCP lo bloquea o marca como no compliant.

## 4. Registro y cierre de etapa

Completar `04-lza-config-notes.md` en el repo de instancia del cliente con:
- Versión de LZA desplegada.
- Fecha del primer despliegue exitoso con configuración real (no la de ejemplo).
- Cualquier decisión que se apartó del default y por qué (ej. approach de federación SSO elegido, criterio de budgets).
- Issues encontrados durante el despliegue y cómo se resolvieron (esto ahorra tiempo en el próximo cliente).

Con esto cerrado, la Organization del cliente está lista para la **Etapa 3 — Workloads**: [`docs/03-workloads/README.md`](../03-workloads/README.md).

## Troubleshooting

Para errores no cubiertos acá, la guía oficial tiene una sección dedicada: https://docs.aws.amazon.com/solutions/latest/landing-zone-accelerator-on-aws/troubleshooting.html
