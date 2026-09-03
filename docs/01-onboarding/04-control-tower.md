# Control Tower (configuración mínima)

## Por qué acá y no directo con LZA

LZA puede desplegarse sobre una Organization "pelada" (sin Control Tower) o integrarse con un Control Tower Landing Zone ya existente. El approach de este equipo es: **Control Tower primero, con lo mínimo indispensable**, y después LZA encima. Razones:
- Control Tower resuelve rápido lo repetitivo: cuentas `Log Archive` y `Audit`, CloudTrail organizacional, AWS Config, guardrails básicos.
- LZA soporta explícitamente extender un Control Tower existente, así que no es trabajo duplicado.

## Pasos (consola — Control Tower no tiene una CLI de setup inicial completa, se hace desde la consola)

1. **Elegir Home Region.** Debe ser la región principal de operación del cliente (definida en el relevamiento). No se puede cambiar después sin re-crear la landing zone, así que confirmarla con el cliente antes de tocar nada.
2. **Regiones adicionales gobernadas.** Agregar solo las que el cliente va a usar realmente (cada región gobernada suma cuentas/recursos a mantener). Se pueden agregar más después.
3. **OU inicial.** Control Tower crea `Security` con `Log Archive` y `Audit`. No crear OUs de workload todavía acá — eso lo maneja LZA en `organization-config.yaml` (Etapa 2) para que quede versionado.
4. **Emails de Log Archive y Audit.** Usar la misma convención de emails definida en el relevamiento (ej. `aws+<cliente>-logarchive@...`, `aws+<cliente>-audit@...`).
5. **CloudTrail organizacional:** dejar habilitado (default de Control Tower).
6. **AWS Config:** dejar habilitado (default).
7. **Retención de logs:** ajustar según lo relevado (sección "Logging y retención" del intake) si el default de Control Tower no alcanza.
8. **AWS IAM Identity Center:** habilitar durante el setup si el cliente va a usar Identity Center como IdP (definido en el relevamiento). Si usa un IdP externo, esto se configura como federación en un paso posterior (puede hacerse ahora la habilitación básica y la federación se detalla en Etapa 2/LZA).
9. **Lanzar la Landing Zone** y esperar a que termine el aprovisionamiento (puede tardar 30-60 min).

## Validación post-despliegue

- [ ] Cuentas `Log Archive` y `Audit` creadas y visibles en Organizations.
- [ ] CloudTrail organizacional activo, log bucket en `Log Archive`.
- [ ] AWS Config activo en todas las cuentas gobernadas.
- [ ] Identity Center accesible (si se habilitó) con el usuario admin inicial.
- [ ] Guardrails mandatorios de Control Tower en estado "Compliant" en el dashboard.

## Registro

Documentar en `04-control-tower-checklist.md` del repo de instancia: Account IDs de Log Archive y Audit, home region elegida, regiones gobernadas, fecha de despliegue.

## Siguiente paso

Con esto, la Etapa 1 está cerrada. El relevamiento completo + esta base de Control Tower son el input de la **Etapa 2 — Landing Zone Accelerator**: [`docs/02-landing-zone-accelerator/README.md`](../02-landing-zone-accelerator/README.md).
