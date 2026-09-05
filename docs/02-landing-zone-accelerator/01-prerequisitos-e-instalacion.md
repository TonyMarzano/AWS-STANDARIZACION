# Prerrequisitos e instalación

## Prerrequisitos (deben venir cerrados de la Etapa 1)

- [ ] AWS Organizations habilitado con `--feature-set ALL` en la cuenta management.
- [ ] Control Tower desplegado (Landing Zone base activa). LZA está pensado para **complementar** Control Tower, no reemplazarlo — por eso instalamos con `ControlTowerEnabled=Yes`.
- [ ] Cuentas `Log Archive` y `Audit` creadas **y enroladas en Control Tower** en una OU con el baseline clásico habilitado — ver [`docs/01-onboarding/04-control-tower.md`](../01-onboarding/04-control-tower.md#landing-zone-40-qué-cambió-y-por-qué-importa). Desde Landing Zone 4.0 (nov-2025), esto ya no lo hace Control Tower solo: hay que crearlas a mano y enrolarlas explícitamente **antes** de instalar LZA, o el pipeline falla en el stage `Prepare` con un error de `sts:AssumeRole` sobre `AWSControlTowerExecution`.
- [ ] Home region y regiones gobernadas ya decididas (no cambian entre etapas).
- [ ] Emails de las cuentas Management, Log Archive y Audit confirmados — el installer los pide y **deben coincidir exactamente** con los de las cuentas ya existentes en la Organization.
- [ ] Formulario de intake del cliente completo (es el insumo de [`02-mapeo-configuracion.md`](02-mapeo-configuracion.md)).

## 1. Token de GitHub (lectura del código fuente de LZA)

El pipeline de instalación descarga el código fuente del acelerador desde GitHub. Para evitar rate-limiting de la API pública:

1. Crear un **Personal Access Token (classic)** en GitHub con scope `public_repo` únicamente (no necesita más permisos).
2. Guardarlo en **AWS Secrets Manager**, en la cuenta management, en la home region elegida, con el nombre **exacto**:
   ```
   accelerator/github-token
   ```
   ```powershell
   aws secretsmanager create-secret `
     --name accelerator/github-token `
     --secret-string "<el-token>" `
     --profile <perfil-cuenta-management> `
     --region <home-region>
   ```
3. Este token es de BGH (o de una cuenta de servicio propia), no del cliente — se reutiliza entre instalaciones si el rate-limit no es un problema, pero recomendamos uno dedicado por seguridad y trazabilidad.

## 2. Obtener el template del Installer Stack

**Recomendado — usar directamente la URL pública de AWS Solutions, sin descargar ni compilar nada:**

```
https://s3.amazonaws.com/solutions-reference/landing-zone-accelerator-on-aws/latest/AWSAccelerator-InstallerStack.template
```

Solo si se necesita customizar el código fuente (poco común, solo si hay un fork propio con cambios): clonar el repo, `yarn install`, y correr `yarn build && yarn cdk synth` dentro de `source/packages/@aws-accelerator/installer/` para generar el template localmente.

## 3. Desplegar el Installer Stack

Se lanza **en la cuenta management, en la home region**. Validado que funciona bien directo por CLI con `--template-url` (no hace falta pasar por la consola):

```powershell
aws cloudformation create-stack `
  --stack-name AWSAccelerator-InstallerStack `
  --template-url https://s3.amazonaws.com/solutions-reference/landing-zone-accelerator-on-aws/latest/AWSAccelerator-InstallerStack.template `
  --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND `
  --profile <perfil-cuenta-management> `
  --region <home-region> `
  --parameters `
    ParameterKey=ManagementAccountEmail,ParameterValue="<email-management>" `
    ParameterKey=LogArchiveAccountEmail,ParameterValue="<email-logarchive>" `
    ParameterKey=AuditAccountEmail,ParameterValue="<email-audit>" `
    ParameterKey=ControlTowerEnabled,ParameterValue="Yes" `
    ParameterKey=ApprovalStageNotifyEmailList,ParameterValue="<email-notificaciones>" `
    ParameterKey=ConfigurationRepositoryLocation,ParameterValue="codecommit"
```

**Parámetros clave:**

| Parámetro | Valor típico |
|---|---|
| `RepositoryName` / `RepositoryBranchName` | Repo y branch de origen del código del acelerador — dejar default (el público de AWS Labs, última release) salvo que BGH mantenga un fork propio |
| `ManagementAccountEmail` | Email de la cuenta management (debe matchear la cuenta real) |
| `LogArchiveAccountEmail` | Email de la cuenta Log Archive — **debe ser una cuenta ya creada y enrolada en Control Tower** (ver prerrequisitos arriba) |
| `AuditAccountEmail` | Email de la cuenta Audit — mismo requisito |
| `ControlTowerEnabled` | `Yes` (ya desplegamos CT en la Etapa 1) |
| `EnableApprovalStage` | `Yes` — agrega un gate de aprobación manual antes de que el pipeline aplique cambios. Recomendado siempre en cuentas de cliente real. |
| `ApprovalStageNotifyEmailList` | Emails que reciben la notificación de aprobación pendiente (típicamente el ingeniero a cargo) |
| `ConfigurationRepositoryLocation` | **Obligatorio, no tiene default.** Usar `codecommit` para el caso simple (repo de configuración nuevo, gestionado por el propio stack) |
| `UseExistingConfigRepo` | Dejar en `No` (default) salvo que se esté reusando un repo de configuración de una instalación anterior |

## 4. Qué queda desplegado

Al terminar el stack del instalador:

- Un pipeline en **CodePipeline** llamado `AWSAccelerator-Pipeline` en la cuenta management.
- Un repositorio en **CodeCommit** (`aws-accelerator-config`) que contiene los 7 archivos YAML de configuración, inicializados con la **configuración de ejemplo** de AWS (no la del cliente todavía).
- Buckets S3 de assets/artifacts y los roles IAM que el pipeline necesita para operar cross-account.

El pipeline corre automáticamente una primera vez con la config de ejemplo. **Es esperable que esa primera corrida no represente lo que el cliente necesita** — se corrige reemplazando la configuración en el paso siguiente, no editando manualmente lo que quedó desplegado.

## Siguiente paso

[`02-mapeo-configuracion.md`](02-mapeo-configuracion.md)
