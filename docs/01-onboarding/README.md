# Etapa 1 — Onboarding

Checklist maestro de la etapa. Cada paso linkea al detalle.

## Flujo

1. [ ] **Relevamiento** — completar el formulario de intake con el cliente → [`01-relevamiento.md`](01-relevamiento.md) / template a llenar: [`templates/client-intake-form.md`](../../templates/client-intake-form.md)
2. [ ] **Creación de cuenta management** — convención de emails + alta de la cuenta AWS → [`02-creacion-cuentas.md`](02-creacion-cuentas.md)
3. [ ] **Baseline de seguridad** — MFA root, budgets, Organizations → [`03-baseline-seguridad.md`](03-baseline-seguridad.md)
4. [ ] **Control Tower mínimo** → [`04-control-tower.md`](04-control-tower.md)
5. [ ] Entregar el intake completo + evidencia de baseline como input a la Etapa 2 (LZA)

## Criterio de salida de la etapa

La Etapa 1 se da por cerrada cuando:

- El formulario de intake del cliente está 100% completo (sin TBDs en los campos obligatorios).
- La cuenta management tiene MFA en root, alternate contacts configurados, y budgets activos.
- AWS Organizations está habilitado con "todas las features" (no solo consolidated billing).
- Control Tower está desplegado con la Landing Zone base activa (Log Archive y Audit account creadas automáticamente).
- Todo lo anterior está registrado en el repo de instancia del cliente (copiado de `templates/client-instance/`).
