# Mapeo: relevamiento → archivos de configuración de LZA

LZA se configura íntegramente vía 7 archivos YAML en el repo CodeCommit `aws-accelerator-config`. Esta tabla traduce cada sección del [formulario de intake](../../templates/client-intake-form.md) al archivo (y, cuando corresponde, la clave) donde se define. La referencia completa y actualizada de cada schema está en los TypeDocs oficiales (linkeados abajo) — **verificar siempre contra la versión de LZA instalada**, porque las claves pueden agregar campos entre versiones.

| Archivo | Para qué sirve (definición oficial) | Referencia |
|---|---|---|
| `accounts-config.yaml` | Gestiona todas las cuentas AWS dentro de la Organization | [AccountsConfig](https://awslabs.github.io/landing-zone-accelerator-on-aws/latest/typedocs/interfaces/packages__aws-accelerator_config_lib_models_accounts-config.IAccountsConfig.html) |
| `organization-config.yaml` | Gestiona OUs y políticas (SCPs, tagging policies) de la Organization | [OrganizationConfig](https://awslabs.github.io/landing-zone-accelerator-on-aws/latest/typedocs/interfaces/packages__aws-accelerator_config_lib_models_organization-config.IOrganizationConfig.html) |
| `global-config.yaml` | Propiedades globales heredadas por toda la Organization (regiones, logging, reports) | [GlobalConfig](https://awslabs.github.io/landing-zone-accelerator-on-aws/latest/typedocs/interfaces/packages__aws-accelerator_config_lib_models_global-config.IGlobalConfig.html) |
| `iam-config.yaml` | Recursos de IAM en toda la Organization (Identity Center, roles, políticas, federación) | [IamConfig](https://awslabs.github.io/landing-zone-accelerator-on-aws/latest/typedocs/interfaces/packages__aws-accelerator_config_lib_models_iam-config.IIamConfig.html) |
| `network-config.yaml` | Topología de red (VPCs, Transit Gateway, IPAM, Network Firewall) | [NetworkConfig](https://awslabs.github.io/landing-zone-accelerator-on-aws/latest/typedocs/interfaces/packages__aws-accelerator_config_lib_models_network-config.INetworkConfig.html) |
| `security-config.yaml` | Configuración de servicios de seguridad de AWS (GuardDuty, Security Hub, Config, etc.) | [SecurityConfig](https://awslabs.github.io/landing-zone-accelerator-on-aws/latest/typedocs/interfaces/packages__aws-accelerator_config_lib_models_security-config.ISecurityConfig.html) |
| `customizations-config.yaml` (opcional) | Stacks de CloudFormation / aplicaciones custom fuera del set estándar | [CustomizationsConfig](https://awslabs.github.io/landing-zone-accelerator-on-aws/latest/typedocs/interfaces/packages__aws-accelerator_config_lib_models_customizations-config.ICustomizationsConfig.html) |

## Mapeo por sección del intake

### 1. Datos generales → `global-config.yaml`
- Región geográfica del cliente → `homeRegion` (debe ser la misma decidida en Control Tower, Etapa 1) y `enabledRegions`.
- Requisitos de compliance → no hay un campo único; condicionan qué guardrails/Config Rules se activan en `security-config.yaml` (ver más abajo) y eventualmente stacks custom en `customizations-config.yaml`.

### 2. Estructura de cuentas y OUs → `organization-config.yaml` + `accounts-config.yaml`
- Árbol de OUs del intake (Security / Infrastructure / Workloads → Prod, NonProd / Sandbox) → `organizationalUnits` en `organization-config.yaml`.
- Cada cuenta listada en el intake (nombre, propósito, OU, email) → entrada en `workloadAccounts` de `accounts-config.yaml`, con su `organizationalUnit` apuntando al nodo del árbol anterior. Las cuentas `management`, `logArchive` y `audit` van en `mandatoryAccounts` y ya deberían coincidir con lo creado en la Etapa 1.

### 3. Convención de emails → `accounts-config.yaml`
- El campo `email` de cada cuenta nueva sigue el patrón acordado en el intake (sección 3). AWS exige que sea único a nivel global — no reutilizable ni con cuentas de otro cliente.

### 4. Red (CIDR) → `network-config.yaml`
- CIDR global/por ambiente del intake → `vpcs[].cidrs` o pools de `centralNetworkServices.ipams` si se decidió centralizar con IPAM.
- Transit Gateway (si el intake definió networking centralizado) → `transitGateways`.
- Conectividad híbrida (VPN/DX) relevada → `transitGateways[].peering` / recursos de VPN o Direct Connect Gateway según corresponda.

### 5. Identidad y accesos (SSO) → `iam-config.yaml`
- Si el cliente usa IAM Identity Center nativo: grupos y permission sets del intake → `identityCenter.identityCenterPermissionSets` y sus asignaciones.
- Si el cliente federa con un IdP externo (Azure AD/Okta/etc.): la metadata SAML relevada configura el `identityCenter` como broker o un `samlProviders` según el patrón elegido — este es el punto del mapeo con más variantes; validar contra la versión de LZA instalada antes de definir el approach.
- Usuarios iniciales del intake → normalmente se gestionan en el IdP (no en LZA directamente) y solo se referencian por grupo en los permission sets.

### 6. Budgets y alarmas
- LZA no reemplaza necesariamente el budget creado en la Etapa 1 (`New-BudgetAlarm.ps1`) sobre la cuenta management. Evaluar caso a caso si conviene definir budgets adicionales por cuenta/OU vía `global-config.yaml` (sección de `reports`/`budgets` si la versión instalada la soporta) o mantener el control centralizado ya creado manualmente. **Definir el criterio la primera vez y dejarlo escrito acá**, para no repetir la discusión por cliente.

### 7. Tagging → `organization-config.yaml`
- Tags obligatorios del intake → `taggingPolicies` (Organizations Tag Policies) y, si se requiere enforcement duro, una SCP complementaria en `security-config.yaml`/`organization-config.yaml` que deniegue creación de recursos sin esos tags.

### 8. Logging y retención → `global-config.yaml` + `security-config.yaml`
- Retención relevada → `logging.cloudtrail`, `logging.sessionManager`, y retención de `cloudwatchLogs` en `global-config.yaml`.
- Acceso de lectura del cliente a logs centralizados → permisos adicionales sobre el bucket de `Log Archive`, normalmente vía un permission set de solo lectura en `iam-config.yaml` con alcance a esa cuenta específica.

## Cómo trabajar esto en la práctica

1. Clonar el repo `aws-accelerator-config` (CodeCommit, cuenta management) localmente.
2. Reemplazar la configuración de ejemplo, sección por sección, siguiendo la tabla de arriba.
3. Documentar en `04-lza-config-notes.md` del repo de instancia del cliente cualquier decisión que se aparte del default de LZA, con el porqué.
4. No commitear a `main`/`branch` de producción sin haber revisado el diff completo — un `cdk diff` mental o, si el flujo lo permite, usar una branch de prueba antes de mergear.

## Siguiente paso

[`03-despliegue-y-validacion.md`](03-despliegue-y-validacion.md)
