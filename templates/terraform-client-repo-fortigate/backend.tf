# State remoto en la cuenta Shared Services.
#
# Los valores del backend no admiten variables. Credenciales: las del perfil Management; el backend
# asume AWSControlTowerExecution en Shared Services para leer/escribir el bucket.

terraform {
  backend "s3" {
    bucket       = "<cliente>-tfstate-<account-id-shared-services>-<home-region>"
    key          = "networking/terraform.tfstate"
    region       = "<home-region>"
    encrypt      = true
    use_lockfile = true # locking nativo de S3 (Terraform >= 1.10), no hace falta DynamoDB

    assume_role = {
      role_arn = "arn:aws:iam::<account-id-shared-services>:role/AWSControlTowerExecution"
    }
  }
}
