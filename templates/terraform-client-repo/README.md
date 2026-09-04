# tf-[NOMBRE DEL CLIENTE]

Terraform de las cargas de trabajo de [NOMBRE DEL CLIENTE], sobre la Landing Zone desplegada vía Control Tower + LZA.

Ver la metodología completa de esta etapa en el repo `AWS-STANDARIZACION`, [`docs/03-workloads/`](https://github.com/TonyMarzano/AWS-STANDARIZACION/tree/main/docs/03-workloads).

## Antes de tocar este repo

1. El backend de state (S3 + DynamoDB) debe existir en la cuenta Shared Services del cliente — ver [`02-backend-state.md`](https://github.com/TonyMarzano/AWS-STANDARIZACION/blob/main/docs/03-workloads/02-backend-state.md) para el bootstrap.
2. Completar los datos reales en cada `backend.tf` y `providers.tf` de este skeleton (bucket, tabla de locks, región, account IDs).

## Estructura

```
envs/
  prod/
    network/       VPC + attachment al Transit Gateway central — desplegar primero
    <workload>/     Copiar este patrón por cada carga de trabajo (ALB, compute, etc.)
  nonprod/
    network/
    <workload>/
```

## Datos del cliente

| Campo | Valor |
|---|---|
| Bucket de state | `tf-state-<cliente>` |
| Tabla de locks | `tf-locks-<cliente>` |
| Región | |
| Cuenta Shared Services (Account ID) | |
| Cuenta Prod (Account ID) | |
| Cuenta NonProd (Account ID) | |
