# Notas de configuración de LZA — [NOMBRE DEL CLIENTE]

> Se completa en la Etapa 2. Ver [`docs/02-landing-zone-accelerator/README.md`](../../docs/02-landing-zone-accelerator/README.md).

- Versión de LZA desplegada: `______`
- Ubicación del repo de configuración del cliente (CodeCommit): `______`
- Fecha del primer despliegue exitoso con configuración real: `______`
- Approach de SSO elegido (Identity Center nativo / federado, IdP): `______`
- Criterio de budgets adoptado (mantener el de Etapa 1 / definir por OU en `global-config.yaml`): `______`
- Decisiones clave tomadas (que se apartan del default de LZA) y por qué: `______`
- Issues encontrados durante el despliegue y cómo se resolvieron: `______`

## Checklist de validación

- [ ] Pipeline `AWSAccelerator-Pipeline` en `Succeeded` con config real
- [ ] Cuentas creadas en la OU correcta
- [ ] Guardrails de `security-config.yaml` compliant
- [ ] Red de `network-config.yaml` desplegada sin solapamiento de CIDRs
- [ ] Permission sets probados con login real
