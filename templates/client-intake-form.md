# Formulario de Intake — Landing Zone [NOMBRE DEL CLIENTE]

> Completar este formulario en la carpeta de instancia del cliente, como `00-intake.md`. Ver el porqué de cada sección en [`docs/01-onboarding/01-relevamiento.md`](../docs/01-onboarding/01-relevamiento.md).
>
> Fecha de inicio del relevamiento: `YYYY-MM-DD`
> Responsable BGH: `Nombre`
> Estado: `[ ] Borrador  [ ] Validado con el cliente  [ ] Cerrado`

## 1. Datos generales

| Campo | Valor |
|---|---|
| Razón social | |
| Contacto técnico (nombre, email, tel) | |
| Contacto de facturación | |
| Dominio de correo del cliente | |
| ¿Tiene cuenta(s) AWS existentes? | Sí / No — detalle |
| Región geográfica / huso horario | |
| Requisitos de compliance | |

## 2. Estructura de cuentas y OUs

| OU | Cuenta | Propósito | Email de la cuenta |
|---|---|---|---|
| Security | Log Archive | (autogenerada por Control Tower) | |
| Security | Audit | (autogenerada por Control Tower) | |
| Infrastructure | Shared Services / Network | | |
| Workloads | Prod | | |
| Workloads | NonProd | | |
| Sandbox | Sandbox | | |

## 3. Convención de emails

- Patrón acordado: `aws+<cliente>-<cuenta>@___________`
- Dominio usado: BGH / del cliente
- Casilla que centraliza la recepción: `______`

## 4. Red (CIDR)

| Ambiente/Cuenta | CIDR asignado | Notas |
|---|---|---|
| Global (Organization) | | |
| Prod | | |
| NonProd | | |
| Shared Services | | |
| Sandbox | | |

- Conectividad híbrida (VPN/DX): Sí / No — rangos on-prem a evitar: `______`
- Networking centralizado en Etapa 2 (LZA - TGW/IPAM): Sí / No

## 5. Identidad y accesos (SSO)

- IdP: AWS IAM Identity Center nativo / Federado (especificar: Azure AD, Okta, otro)
- Metadata SAML / Tenant ID (si aplica): `______`
- Responsable del IdP del lado del cliente: `______`

### Grupos / Permission Sets

| Grupo | Permission Set | Alcance (OU/cuentas) |
|---|---|---|
| | | |

### Usuarios iniciales

| Nombre | Email | Grupo | BGH / Cliente |
|---|---|---|---|
| | | | |

- Política de MFA: `______`

## 6. Budgets y alarmas

| Alcance | Monto mensual (USD) | Umbrales de alerta | Emails de notificación |
|---|---|---|---|
| Total Organization | | 50/80/100% | |

## 7. Tagging

| Tag | Obligatorio | Valores esperados |
|---|---|---|
| Environment | Sí | prod / nonprod / sandbox |
| CostCenter | | |
| Owner | | |
| Cliente | Sí | |

## 8. Logging y retención

- Retención de CloudTrail/Config requerida: `______`
- ¿Cliente necesita acceso de lectura a logs centralizados?: Sí / No

## 9. Notas adicionales

`______`
