# Prerrequisitos e instalación

## Prerrequisitos (deben venir cerrados de la Etapa 1)

- [ ] AWS Organizations habilitado con `--feature-set ALL` en la cuenta management.
- [ ] Control Tower desplegado (Landing Zone base activa, cuentas `Log Archive` y `Audit` creadas). LZA está pensado para **complementar** Control Tower, no reemplazarlo — por eso instalamos con `ControlTowerEnabled=Yes`.
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

Dos caminos:

- **Recomendado (uso normal):** descargar el template CloudFormation ya publicado por AWS Solutions desde la página de la solución (ver "AWS CloudFormation template" en el [Implementation Guide](https://docs.aws.amazon.com/solutions/latest/landing-zone-accelerator-on-aws/aws-cloudformation-template.html)).
- **Si se necesita customizar el código fuente** (poco común, solo si hay un fork propio con cambios): clonar el repo, `yarn install`, y correr `yarn build && yarn cdk synth` dentro de `source/lza/` para generar `AWSAccelerator-InstallerStack.template.json` localmente.

## 3. Desplegar el Installer Stack

Se lanza **en la cuenta management, en la home region**, vía consola de CloudFormation o CLI.

**Parámetros clave:**

| Parámetro | Valor típico |
|---|---|
| `RepositoryName` / `RepositoryBranchName` | Repo y branch de origen del código del acelerador (el público de AWS Labs, salvo que BGH mantenga un fork propio) |
| `ManagementAccountEmail` | Email de la cuenta management (debe matchear la cuenta real) |
| `LogArchiveAccountEmail` | Email de la cuenta Log Archive creada por Control Tower |
| `AuditAccountEmail` | Email de la cuenta Audit creada por Control Tower |
| `ControlTowerEnabled` | `Yes` (ya desplegamos CT en la Etapa 1) |
| `EnableApprovalStage` | `Yes` — agrega un gate de aprobación manual antes de que el pipeline aplique cambios. Recomendado siempre en cuentas de cliente real. |
| `ApprovalStageNotifyEmailList` | Emails que reciben la notificación de aprobación pendiente (típicamente el ingeniero a cargo) |

## 4. Qué queda desplegado

Al terminar el stack del instalador:

- Un pipeline en **CodePipeline** llamado `AWSAccelerator-Pipeline` en la cuenta management.
- Un repositorio en **CodeCommit** (`aws-accelerator-config`) que contiene los 7 archivos YAML de configuración, inicializados con la **configuración de ejemplo** de AWS (no la del cliente todavía).
- Buckets S3 de assets/artifacts y los roles IAM que el pipeline necesita para operar cross-account.

El pipeline corre automáticamente una primera vez con la config de ejemplo. **Es esperable que esa primera corrida no represente lo que el cliente necesita** — se corrige reemplazando la configuración en el paso siguiente, no editando manualmente lo que quedó desplegado.

## Siguiente paso

[`02-mapeo-configuracion.md`](02-mapeo-configuracion.md)
