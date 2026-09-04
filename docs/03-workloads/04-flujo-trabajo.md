# Flujo de trabajo

## Alta de un cliente nuevo (una vez)

1. Crear el repo `tf-<cliente>` (privado) y copiar el contenido de [`templates/terraform-client-repo/`](../../templates/terraform-client-repo/).
2. Bootstrap del backend de state (ver [`02-backend-state.md`](02-backend-state.md)) en la cuenta Shared Services del cliente.
3. Completar `backend.tf` y `providers.tf` de cada componente con los datos reales (bucket, tabla, región, account ID vía `assume_role` o profile).
4. Desplegar primero `envs/<ambiente>/network/` — todo lo demás depende de esto.

## Alta de un workload nuevo (recurrente)

1. Crear la carpeta `envs/<ambiente>/<workload>/` copiando el patrón de otro componente existente.
2. Referenciar los módulos necesarios desde `terraform-modules-bgh` (ver [`03-modulos-reutilizables.md`](03-modulos-reutilizables.md)), fijando siempre una versión (`?ref=vX.Y.Z`).
3. Leer lo necesario de `network` vía `terraform_remote_state` (VPC ID, subnets, security group base) — nunca hardcodear esos valores.
4. `terraform init && terraform plan` → revisar el plan → `terraform apply` solo después de revisión.

## Tagging

Los tags obligatorios ya quedaron definidos en el intake de la Etapa 1 y aplicados como Tag Policy/SCP en la Etapa 2 (LZA). Acá se heredan, no se reinventan: configurar `default_tags` a nivel `provider` en cada `providers.tf` para no tener que repetir tags en cada recurso:

```hcl
provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Cliente     = "<cliente>"
      Environment = "prod"
      Owner       = "cloud-ops@bghtechpartner.com"
    }
  }
}
```

Si un recurso queda sin un tag obligatorio, la SCP/Tag Policy de la Etapa 2 debería frenarlo o marcarlo — es la señal de que algo en `providers.tf` está mal configurado.

## Revisión y aplicación de cambios

- Todo cambio pasa por Pull Request contra `main`, nunca `apply` directo desde el laptop del ingeniero salvo el bootstrap inicial.
- Si hay CI/CD configurado (recomendado en cuanto haya más de un ingeniero tocando el mismo cliente): pipeline que corre `terraform plan` en cada PR y comenta el resultado, y `terraform apply` solo al mergear a `main` (o con aprobación manual, igual que el `EnableApprovalStage` de LZA en la Etapa 2 — mismo principio de gate antes de aplicar en cuentas reales).
- Nombrar los PRs y commits de forma que quede claro qué componente y qué ambiente tocan (ej. `prod/network: agrega subnet para RDS`).

## Checklist de cierre por workload

- [ ] `terraform plan` sin cambios pendientes después del último `apply` (estado limpio).
- [ ] Outputs de `network` consumidos vía remote state, no hardcodeados.
- [ ] Módulos referenciados con `?ref=` fijo, nunca a una branch.
- [ ] Tags obligatorios presentes (validar contra la Tag Policy de la Etapa 2).
- [ ] Documentado en `05-workloads-notes.md` del repo de instancia del cliente: qué workload es, en qué repo/carpeta vive, y cualquier decisión particular.

## Cierre de la Landing Zone completa

Con esto, las 3 etapas están cerradas para el cliente. El entregable documental combina:

- El repo de instancia del cliente (`00-intake.md` a `05-workloads-notes.md`).
- El repo `tf-<cliente>` con su Terraform.
- El repo de configuración de LZA (`aws-accelerator-config`, CodeCommit).

Ese conjunto es lo que se traduce en el documento final para el cliente.
