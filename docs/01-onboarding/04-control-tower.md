# Control Tower (configuración mínima)

> **Actualizado 2026-09-05** tras una práctica end-to-end contra una cuenta real. Desde noviembre 2025 AWS despliega por default **Landing Zone versión 4.0**, que cambia bastante el flujo respecto a versiones anteriores de Control Tower. Esta guía ya refleja ese comportamiento — si en algún momento AWS vuelve a cambiar el wizard, actualizar acá.

## Por qué acá y no directo con LZA

LZA puede desplegarse sobre una Organization "pelada" (sin Control Tower) o integrarse con un Control Tower Landing Zone ya existente. El approach de este equipo es: **Control Tower primero, con lo mínimo indispensable**, y después LZA encima.

## Landing Zone 4.0: qué cambió y por qué importa

LZ4.0 (release del 17-nov-2025) introdujo un modelo de "Controls-Only / integraciones opcionales":

- **Ya no exige una OU "Security"** con cuentas `Log Archive`/`Audit` obligatorias como en versiones anteriores.
- Cada integración de servicio (AWS Config, CloudTrail, Security Roles, Backup) es **opcional**, y se le asigna una **cuenta "hub"** propia al habilitarla (puede ser una cuenta nueva creada ahí mismo en el wizard).
- Una OU que aloja una cuenta hub de integración de servicio queda **incompatible con el baseline clásico de Control Tower** (el que da el rol `AWSControlTowerExecution` necesario para que herramientas externas — como LZA — puedan operar sobre esas cuentas).
- El wizard **no crea ninguna cuenta `Log Archive` ni `Audit`** por sí solo.

**Consecuencia práctica:** como LZA (a la fecha, v1.16.2) todavía espera el modelo clásico con `Log Archive`/`Audit` como cuentas separadas con el rol de ejecución de Control Tower, hay que crearlas y enrolarlas a mano. Ver el procedimiento completo más abajo.

## Planificación de OUs — hacerlo bien desde el arranque

Para evitar el vaivén de mover cuentas entre OUs (que nos pasó en la práctica), **crear 2 OUs desde el principio**, antes de terminar el wizard si es posible o inmediatamente después:

| OU | Propósito | Baseline |
|---|---|---|
| `Security` (o el nombre que el wizard te deje elegir para el "Default OU for service integrations") | Aloja las cuentas "hub" de integraciones de servicio (Config, CloudTrail, etc.) | Ninguno clásico — queda gestionada por el modelo de integraciones de LZ4.0. En LZA, se declara con `ignore: true` |
| `Workloads` (o `Governed`, a definir con el cliente) | Aloja Log Archive, Audit, y cuentas de carga de trabajo | AWS Control Tower baseline clásico — se habilita solo al crear la OU vía Control Tower, no vía Organizations directo |

## Pasos (consola — Control Tower no tiene una CLI de setup inicial completa)

1. **Elegir Home Region.** Debe ser la región principal de operación del cliente. No se puede cambiar después sin re-crear la landing zone.
2. **Regiones adicionales gobernadas.** Agregar solo las que el cliente va a usar realmente.
3. **Setup preference:** "I want to set up a full environment" (para un ambiente nuevo).
4. **Configure Service integrations (Step 3, opcional pero con dependencias reales):**
   - **AWS Config:** habilitarlo y usar **"Create new"** para la cuenta aggregator (no hay una cuenta existente todavía en un ambiente nuevo). Esto es un prerrequisito real para poder gestionar IAM Identity Center más abajo — no se puede omitir si querés que Control Tower gestione Identity Center.
   - **AWS CloudTrail Centralized logging:** se puede dejar en "Disable" (el CloudTrail organizacional base de Control Tower no depende de esto). Evaluar con el cliente si conviene habilitarlo.
   - **IAM Identity Center account access:** elegir "AWS Control Tower sets up AWS account access with IAM Identity Center" (nuestro approach por default) — recién queda seleccionable después de habilitar Config.
   - **AWS Backup:** "Don't enable AWS Backup" para el mínimo (se puede sumar después).
5. **Lanzar la Landing Zone** y esperar el aprovisionamiento (30-60 min).
6. **Crear la segunda OU** (`Workloads` o el nombre elegido) desde Control Tower (Organization → Create resources → Create organizational unit) — **no** desde Organizations directo, porque solo así queda con el baseline clásico habilitado automáticamente. Confirmar en sus Details que "AWS Control Tower baseline status: Enabled".
7. **Fix de permisos, una vez por Organization:** asociar el IAM admin que va a operar (ej. `cli-admin`) al portfolio de Service Catalog de Account Factory, si no se hizo ya:
   ```powershell
   $PortfolioId = (aws servicecatalog list-portfolios --profile <perfil> --region <home-region> --query "PortfolioDetails[?DisplayName=='AWS Control Tower Account Factory Portfolio'].Id" --output text)
   aws servicecatalog associate-principal-with-portfolio `
     --portfolio-id $PortfolioId `
     --principal-arn <arn-del-iam-admin> `
     --principal-type IAM `
     --profile <perfil> --region <home-region>
   ```
8. **Crear Log Archive y Audit manualmente** (con los emails del intake):
   ```powershell
   aws organizations create-account --email "<email-logarchive>" --account-name "<cliente>-logarchive" --profile <perfil>
   aws organizations create-account --email "<email-audit>" --account-name "<cliente>-audit" --profile <perfil>
   ```
9. **Enrolarlas en Control Tower**, en la OU con baseline clásico (`Workloads`): consola de Control Tower → Organization → seleccionar la cuenta → **Enroll account** → elegir esa OU. Repetir para las dos.

## Validación post-despliegue

- [ ] Landing Zone en estado activo, versión confirmada (revisar en Landing zone settings → Details).
- [ ] OU de integraciones de servicio (`Security`) con la cuenta hub creada.
- [ ] OU `Workloads` con "AWS Control Tower baseline status: Enabled".
- [ ] Log Archive y Audit creadas, movidas y enroladas en `Workloads` (verificar en consola — el enrollment se hereda a nivel de OU, no siempre aparece un registro individual por cuenta vía `aws controltower list-enabled-baselines`, confiar en la consola).
- [ ] Identity Center accesible con el usuario admin inicial.
- [ ] Guardrails mandatorios en estado "Compliant".

## Registro

Documentar en `04-control-tower-checklist.md` del repo de instancia: Account IDs de Log Archive, Audit y de cualquier cuenta hub de integración, IDs de las OUs, home region, regiones gobernadas, fecha de despliegue.

## Siguiente paso

Con esto, la Etapa 1 está cerrada. El relevamiento completo + esta base de Control Tower son el input de la **Etapa 2 — Landing Zone Accelerator**: [`docs/02-landing-zone-accelerator/README.md`](../02-landing-zone-accelerator/README.md).
