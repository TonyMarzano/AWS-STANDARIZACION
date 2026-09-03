# Baseline de seguridad (cuenta management)

Todo esto se hace **antes** de Control Tower, sobre la cuenta management recién creada.

## 1. MFA en el usuario root

El root no se puede asegurar 100% por script porque requiere el secreto TOTP generado en el momento (QR/clave base32) y un código de 6 dígitos válido para confirmarlo. El proceso:

1. Login como root en la consola (único momento en que se debería usar root interactivamente además de tareas que lo requieren explícitamente, como cambiar el plan de soporte).
2. IAM → "Security credentials" → "Assign MFA device" → elegir **virtual MFA device**.
3. Registrar el dispositivo virtual en un gestor de MFA **compartido/institucional** (no el celular personal de una sola persona) — ej. la vault del equipo si soporta TOTP, para que no dependa de una sola persona en caso de ausencia.
4. Confirmar con dos códigos consecutivos.
5. Alternativa recomendada si el volumen de clientes lo justifica: usar una **MFA de hardware (FIDO security key)** custodiada por el equipo para los roots más críticos.

**Checklist de verificación (si querés confirmar por CLI que quedó bien):**
```powershell
aws iam list-virtual-mfa-devices --profile <perfil-cuenta-management>
```

## 2. Alternate contacts

Configurar los contactos alternativos (Billing, Operations, Security) para que las notificaciones de AWS no dependan de una sola persona ni del email de root:

```powershell
aws account put-alternate-contact `
  --alternate-contact-type BILLING `
  --email-address "billing-contact@bghtechpartner.com" `
  --name "BGH Billing" `
  --phone-number "+54 9 11 xxxx-xxxx" `
  --title "Billing Contact" `
  --profile <perfil-cuenta-management>
```
Repetir para `OPERATIONS` y `SECURITY`.

## 3. Budgets & alarms

Script: [`scripts/01-onboarding/New-BudgetAlarm.ps1`](../../scripts/01-onboarding/New-BudgetAlarm.ps1). Usa los umbrales y emails definidos en el relevamiento (sección "Budgets y alarmas").

```powershell
./scripts/01-onboarding/New-BudgetAlarm.ps1 `
  -Profile <perfil-cuenta-management> `
  -MonthlyLimitUSD 1000 `
  -NotificationEmails "cloudops@bghtechpartner.com","cliente@dominio.com" `
  -Thresholds 50,80,100
```

## 4. Baseline de la cuenta (IAM + acceso público S3 a nivel cuenta)

Script: [`scripts/01-onboarding/Set-AccountBaseline.ps1`](../../scripts/01-onboarding/Set-AccountBaseline.ps1). Aplica:
- Password policy de IAM (mínimo de complejidad, rotación, no reuso).
- S3 Block Public Access a nivel cuenta (defensa en profundidad — LZA lo reforzará a nivel Organization en Etapa 2, pero no cuesta nada tenerlo ya en la management).

```powershell
./scripts/01-onboarding/Set-AccountBaseline.ps1 -Profile <perfil-cuenta-management>
```

## 5. Habilitar AWS Organizations

Si la cuenta es nueva, Organizations no está habilitado todavía:

```powershell
aws organizations create-organization --feature-set ALL --profile <perfil-cuenta-management>
```

`--feature-set ALL` es obligatorio (no `CONSOLIDATED_BILLING`) porque Control Tower y LZA requieren todas las features (SCPs, etc.).

## 6. Registro

Documentar en `03-baseline-checklist.md` del repo de instancia del cliente: fecha de cada paso, quién lo hizo, y adjuntar/linkear evidencia (ej. captura de los alternate contacts, ARN del budget creado).

## Siguiente paso

[`04-control-tower.md`](04-control-tower.md)
