# Backend de Terraform state

## Por qué en la cuenta Shared Services del cliente (y no centralizado en BGH)

La cuenta Shared Services ya existe para cuando se llega a esta etapa (la crea LZA en la Etapa 2). Guardar el state ahí, dentro de la propia Organization del cliente:

- Evita que un incidente en una cuenta centralizada de BGH afecte el state de todos los clientes a la vez.
- Facilita que el cliente audite su propio state si el contrato lo requiere, sin darle acceso a infraestructura de otros clientes.
- Sigue el mismo principio de aislamiento por cliente que ya aplicamos en toda la metodología.

## Bootstrap (una sola vez por cliente)

Esto se hace **manualmente, una vez**, antes del primer `terraform apply` de cualquier componente — el backend no puede crearse con el mismo Terraform que lo va a usar (problema del huevo y la gallina).

```powershell
$Profile = "<perfil-cuenta-shared-services-cliente>"
$Region  = "<home-region-del-cliente>"
$Cliente = "<nombre-cliente>"
$BucketName = "tf-state-$Cliente"
$TableName  = "tf-locks-$Cliente"

# Bucket de state: versionado + cifrado + bloqueo de acceso público
aws s3api create-bucket --bucket $BucketName --region $Region `
  --create-bucket-configuration LocationConstraint=$Region --profile $Profile
aws s3api put-bucket-versioning --bucket $BucketName `
  --versioning-configuration Status=Enabled --profile $Profile
aws s3api put-bucket-encryption --bucket $BucketName `
  --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}' `
  --profile $Profile
aws s3api put-public-access-block --bucket $BucketName `
  --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true `
  --profile $Profile

# Tabla de locking
aws dynamodb create-table --table-name $TableName `
  --attribute-definitions AttributeName=LockID,AttributeType=S `
  --key-schema AttributeName=LockID,KeyType=HASH `
  --billing-mode PAY_PER_REQUEST `
  --region $Region --profile $Profile
```

Registrar el nombre del bucket, la tabla y la cuenta en `05-workloads-notes.md` del repo de instancia del cliente — son datos que todo componente nuevo va a necesitar.

## Convención de `key` por componente

Cada componente (`network`, cada workload) tiene su propio state, con una key que refleja ambiente + componente:

```hcl
# envs/prod/network/backend.tf
terraform {
  backend "s3" {
    bucket         = "tf-state-<cliente>"
    key            = "prod/network/terraform.tfstate"
    region         = "<home-region>"
    dynamodb_table = "tf-locks-<cliente>"
    encrypt        = true
  }
}
```

```hcl
# envs/prod/<workload>/backend.tf
terraform {
  backend "s3" {
    bucket         = "tf-state-<cliente>"
    key            = "prod/<workload>/terraform.tfstate"
    region         = "<home-region>"
    dynamodb_table = "tf-locks-<cliente>"
    encrypt        = true
  }
}
```

## Consumir outputs de otro componente (`network` → workload)

Los workloads **nunca** hardcodean el VPC ID o subnet IDs de la red — los leen del state de `network` vía `terraform_remote_state`:

```hcl
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "tf-state-<cliente>"
    key    = "prod/network/terraform.tfstate"
    region = "<home-region>"
  }
}

# uso: data.terraform_remote_state.network.outputs.private_subnet_ids
```

Esto exige que `network/outputs.tf` exponga explícitamente todo lo que los workloads vayan a necesitar (VPC ID, subnet IDs por tier, security group base, etc.) — mantenerlo documentado ahí mismo con comentarios cortos si un output no es autoexplicativo por su nombre.

## Siguiente paso

[`03-modulos-reutilizables.md`](03-modulos-reutilizables.md)
