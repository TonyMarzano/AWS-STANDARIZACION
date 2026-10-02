# tf-[NOMBRE DEL CLIENTE]

Terraform de las cargas de trabajo de [NOMBRE DEL CLIENTE], sobre la Landing Zone desplegada vía Control Tower + LZA.

Ver la metodología completa de esta etapa en el repo `AWS-STANDARIZACION`, [`docs/03-workloads/`](https://github.com/TonyMarzano/AWS-STANDARIZACION/tree/main/docs/03-workloads).

> **¿Este cliente necesita inspección de tráfico con FortiGate?** Este skeleton no lo contempla — usar [`templates/terraform-client-repo-fortigate/`](https://github.com/TonyMarzano/AWS-STANDARIZACION/tree/main/templates/terraform-client-repo-fortigate) en su lugar. Ver la comparación en [`docs/03-workloads/06-arquitectura-red-fortigate.md`](https://github.com/TonyMarzano/AWS-STANDARIZACION/blob/main/docs/03-workloads/06-arquitectura-red-fortigate.md).

## Antes de tocar este repo

1. El backend de state (S3 + DynamoDB) debe existir en la cuenta Shared Services del cliente — ver [`02-backend-state.md`](https://github.com/TonyMarzano/AWS-STANDARIZACION/blob/main/docs/03-workloads/02-backend-state.md) para el bootstrap.
2. Completar los datos reales en cada `backend.tf` y `providers.tf` de este skeleton (bucket, tabla de locks, región, account IDs).

## Estructura

Arquitectura de red de referencia: egress centralizado vía Transit Gateway — las VPCs spoke no tienen salida propia a Internet, **la salida a Internet se centraliza en la cuenta Networking** (NAT); el tráfico entre spokes (Prod↔Dev) viaja directo por el Transit Gateway. Ver el diseño completo, con diagrama, en [`docs/03-workloads/05-arquitectura-red-referencia.md`](https://github.com/TonyMarzano/AWS-STANDARIZACION/blob/main/docs/03-workloads/05-arquitectura-red-referencia.md).

```
envs/
  networking/
    network/        Transit Gateway + VPC de Networking (salida a Internet) — desplegar primero, una sola vez
  prod/
    network/        VPC Workloads Prod (sin salida propia) + attachment al Transit Gateway
    <workload>/     Copiar este patrón por cada carga de trabajo (ALB, compute, etc.)
  nonprod/
    network/        VPC Workloads Dev (sin salida propia) + attachment al Transit Gateway
    <workload>/
```

**Orden de despliegue:** `envs/networking/network` primero → cada cuenta spoke acepta la invitación de RAM del Transit Gateway → recién entonces `envs/prod/network` y `envs/nonprod/network`.

## Datos del cliente

| Campo | Valor |
|---|---|
| Bucket de state | `tf-state-<cliente>` |
| Tabla de locks | `tf-locks-<cliente>` |
| Región | |
| Cuenta Shared Services (Account ID) | |
| Cuenta Networking (Account ID) | |
| Cuenta Prod (Account ID) | |
| Cuenta NonProd/Dev (Account ID) | |
