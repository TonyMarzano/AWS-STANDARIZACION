# Scripts — Etapa 1 (Onboarding)

Scripts PowerShell que envuelven AWS CLI para los pasos repetibles de la Etapa 1. Requieren:

- [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) instalado.
- Un profile de AWS CLI configurado con credenciales de la cuenta management del cliente (`aws configure --profile <nombre>` o SSO).
- PowerShell 5.1+ (Windows) o PowerShell Core.

| Script | Qué hace | Se referencia en |
|---|---|---|
| `New-BudgetAlarm.ps1` | Crea un AWS Budget mensual con alarmas por umbral, notificando por email | [`docs/01-onboarding/03-baseline-seguridad.md`](../../docs/01-onboarding/03-baseline-seguridad.md) |
| `Set-AccountBaseline.ps1` | Aplica password policy de IAM + S3 Block Public Access a nivel cuenta | [`docs/01-onboarding/03-baseline-seguridad.md`](../../docs/01-onboarding/03-baseline-seguridad.md) |

MFA en root **no se scriptea** (requiere interacción con un TOTP en el momento) — ver el paso a paso en el doc de baseline.

## Convención

Todos los scripts:
- Reciben `-Profile` como parámetro obligatorio (nunca hardcodean credenciales).
- Usan `-WhatIf`/confirman antes de crear recursos con costo asociado, cuando aplica.
- No escriben ningún dato de cliente en este repo — los outputs (ARNs, IDs) se copian a mano al repo de instancia del cliente.
