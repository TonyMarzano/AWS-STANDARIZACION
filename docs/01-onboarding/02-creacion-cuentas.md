# Creación de la cuenta management

## Qué se crea acá (y qué no)

En este paso **solo se crea la cuenta management (payer account)** de la Organization. Las cuentas `Log Archive` y `Audit` las crea automáticamente Control Tower al desplegar la Landing Zone base (paso 4). Las cuentas de workload (Prod, NonProd, etc.) se crean en la Etapa 2 vía LZA (`accounts-config.yaml`) o Account Factory de Control Tower — no acá.

## Pasos

1. **Definir el email de la cuenta management** siguiendo la convención acordada en el relevamiento (ej. `aws+<cliente>-management@bghtechpartner.com`).
2. **Crear la cuenta AWS** desde https://portal.aws.amazon.com/billing/signup (o, si BGH ya tiene una Organization paraguas para clientes, evaluar si esta cuenta nace standalone y luego se promueve a management de su propia Organization — normalmente cada cliente tiene su **propia Organization independiente**, no comparte la de BGH).
3. **Registrar el método de pago** correspondiente al cliente (tarjeta o facturación consolidada según el contrato comercial — esto lo suele coordinar administración/ventas, no el cloud engineer, pero hay que confirmar que está hecho antes de seguir).
4. **Verificar el número de teléfono y la dirección** de la cuenta (AWS lo pide en el signup y lo usa para soporte/recuperación).
5. **Guardar las credenciales root de forma segura**:
   - Contraseña generada con gestor de contraseñas (no reutilizable, no memorizable a propósito).
   - Guardar en el vault de credenciales del equipo (ej. 1Password/Bitwarden compartido, con acceso restringido) — **nunca en texto plano ni en este repo**.
6. Confirmar que el email de la cuenta recibe el correo de verificación y quedó confirmado (AWS lo requiere para activar soporte y algunos servicios).

## Registro

Todo esto se documenta en el repo de instancia del cliente, archivo `01-cuentas-y-accesos.md` (ver [`templates/client-instance/`](../../templates/client-instance/)) — ahí van: email de la cuenta, Account ID (una vez creada), y quién tiene el acceso root guardado.

## Siguiente paso

Con la cuenta management creada y accesible, seguir con [`03-baseline-seguridad.md`](03-baseline-seguridad.md).
