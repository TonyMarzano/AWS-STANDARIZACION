# Relevamiento de información

Esto define **qué** hay que preguntar/definir con el cliente antes de tocar la consola de AWS, y **por qué** cada dato importa para las etapas siguientes. El formulario real para completar está en [`templates/client-intake-form.md`](../../templates/client-intake-form.md) — este documento es la guía de referencia de ese formulario.

## 1. Datos generales del cliente

- Razón social, contacto técnico y contacto de facturación.
- Dominio de correo del cliente (para convención de emails de cuentas AWS).
- ¿El cliente ya tiene alguna cuenta AWS existente (aunque sea de prueba/legacy)? Esto cambia el approach: puede requerir invitar cuentas existentes a la Organization en vez de crearlas de cero.
- Zona horaria / región geográfica principal (impacta elección de home region y regiones habilitadas).
- Requisitos de compliance si los hay (PCI, HIPAA, ISO 27001, requisitos locales de residencia de datos) — condiciona guardrails en LZA (Etapa 2).

## 2. Estructura de cuentas y OUs

- ¿Cuántos ambientes necesita? (típico: Prod, Non-Prod/Dev, Shared Services, Sandbox).
- ¿Estructura de OUs esperada? Punto de partida recomendado (alineado a LZA):
  - `Security` (Log Archive, Audit — las crea Control Tower)
  - `Infrastructure` (Network/Shared Services)
  - `Workloads` → `Prod`, `NonProd`
  - `Sandbox`
- Nombre de cada cuenta a crear y a qué OU pertenece.

## 3. Convención de emails

AWS requiere un email único (no reutilizable entre cuentas) por cada cuenta de la Organization.

- Definir el patrón, ej.: `aws+<cliente>-<cuenta>@bghtechpartner.com` o `aws-<cliente>-<cuenta>@dominio-del-cliente.com` usando "plus addressing" para que todo llegue a una casilla monitoreada.
- **Decidir de quién es el dominio**: ¿usamos un dominio de BGH (control total nuestro, recomendado mientras BGH administra) o del cliente? Impacta quién puede resetear el acceso a root.
- Confirmar que la casilla que recibe esos emails tiene alertas configuradas (los emails de root son el canal de recuperación de cuenta).

## 4. Red (CIDR)

- Rango CIDR global asignado a la Organization (para evitar solapamientos entre clientes/cuentas si en algún momento hay conectividad cruzada, ej. DX/VPN compartido).
- Split de CIDR por ambiente/cuenta (Prod, NonProd, Shared Services, Sandbox).
- ¿Hay conectividad híbrida (VPN/Direct Connect) a on-premise del cliente? Si es así, relevar los rangos on-prem para evitar solapamiento.
- ¿Se centraliza el networking en Etapa 2 (Transit Gateway/IPAM vía LZA) o se maneja per-cuenta en Etapa 3? Definir esto ahora evita rehacer VPCs después.

## 5. Identidad y accesos (SSO)

- ¿El cliente tiene un IdP externo (Azure AD/Entra ID, Okta, Google Workspace) para federar, o usamos AWS IAM Identity Center como IdP nativo?
- Si es federado: relevar metadata SAML / tenant ID, y quién del lado del cliente gestiona el IdP.
- Grupos y Permission Sets esperados (ej.: `AWSAdministrators`, `AWSPowerUser`, `AWSReadOnly`, grupos custom por equipo del cliente).
- Usuarios a crear en el arranque (nombre, email, grupo/permission set, ¿son de BGH o del cliente?).
- Política de MFA para usuarios humanos (obligatorio siempre, ¿tipo de MFA permitido?).

## 6. Budgets y alarmas

- Presupuesto mensual esperado (total y, si se puede, por cuenta/ambiente).
- Umbrales de alerta (ej. 50/80/100% del budget, o "actual + forecast").
- Emails/canales que reciben las alertas (¿solo BGH, o también el cliente?).

## 7. Tagging

- Convención de tags obligatorios (ej. `Environment`, `CostCenter`, `Owner`, `Cliente`) — se aplica luego vía SCP/Tag Policies en LZA.

## 8. Logging y retención

- Retención de logs de CloudTrail/Config requerida (default LZA suele ser razonable, pero puede haber requisito contractual del cliente).
- ¿Necesita el cliente acceso de lectura a los logs centralizados (Log Archive account) o eso queda solo para BGH?

---

Con todo esto completo, se pasa a [`02-creacion-cuentas.md`](02-creacion-cuentas.md).
