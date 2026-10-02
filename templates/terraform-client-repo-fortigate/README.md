# tf-[cliente]-networking (variante con FortiGate)

Despliega la red de referencia **con inspección centralizada vía FortiGate**: 4 VPCs (Networking, Shared, Workloads Prod, Workloads QA), un Transit Gateway en la cuenta Network compartido por RAM, y el ruteo de inspección centralizada.

> Alternativa a [`templates/terraform-client-repo/`](../terraform-client-repo/), que no asume ningún appliance de inspección. Usar este template cuando el cliente ya tiene (o va a tener) FortiGate; usar el otro cuando no. Ver la comparación completa en [`docs/03-workloads/06-arquitectura-red-fortigate.md`](../../docs/03-workloads/06-arquitectura-red-fortigate.md).

## Topología

```
 Shared / Prod / QA (spokes)                    Network
 ┌────────────────────┐                ┌──────────────────────────────┐
 │ workload subnets   │ 0.0.0.0/0      │ attachment-tg ──► FortiGate  │──► WAN ──► IGW / VPN on-prem
 │   └─► TGW ─────────┼───► TGW ───────┤   (appliance mode)   LAN     │
 └────────────────────┘  rt_spokes     └──────────────────────────────┘
                                          ▲ rt_inspection (CIDRs de los spokes, propagados)
```

| Route table del TGW | Asociada a | Rutas |
|---|---|---|
| `rt_spokes` | Shared, Prod, QA | `0.0.0.0/0` → attachment de Networking |
| `rt_inspection` | Networking | CIDR de cada spoke (propagación) |

Los spokes no propagan entre sí: todo (Internet, on-prem, spoke↔spoke) pasa por el FortiGate.

## Ruteo por subnet (una route table por subnet)

| VPC / subnet | Rutas |
|---|---|
| Networking `wan` | `0.0.0.0/0` → IGW |
| Networking `lan` | CIDR total del cliente (`supernet_cidr`) → TGW |
| Networking `ha` | solo local |
| Networking `managment-outbound` | `0.0.0.0/0` → IGW *(supuesto, ver abajo)* |
| Networking `attachment-tg` | `0.0.0.0/0` → ENI LAN del FortiGate (`fortigate_lan_eni_ids`) |
| Spokes `attachment-tg` | solo local |
| Spokes `db`, `vpc-endpoints` | `0.0.0.0/0` → TGW |

## Uso

Credenciales de la cuenta **Management** (`aws sso login --profile <cliente>-mgmt`, `AWS_PROFILE=<cliente>-mgmt`). Se asume `AWSControlTowerExecution` en cada cuenta destino.

```bash
cp terraform.tfvars.example terraform.tfvars   # completar cliente y account IDs de cada cuenta
terraform init
terraform plan
terraform apply
```

Prerrequisito: RAM sharing habilitado con la Organization (`aws ram enable-sharing-with-organization` desde Management), o `manage_ram_org_sharing = true`.

## Pendientes / supuestos (ajustar por cliente)

- **FortiGate no incluido.** Este template despliega la red que lo "contempla" (subnets, route tables, el toggle `fortigate_lan_eni_ids`), no las instancias del FortiGate en sí — eso se hace aparte (AMI de AWS Marketplace, ver [`fortigate-terraform-deploy`](https://github.com/fortinet/fortigate-terraform-deploy) de Fortinet). Cuando estén desplegados, pasar las ENI LAN en `fortigate_lan_eni_ids` y re-aplicar. Terraform ignora cambios posteriores de la ENI (el failover HA la mueve).
- **CIDRs y nombres de `locals.tf`** son un ejemplo de referencia (tomado de un relevamiento real) — reemplazar por el del cliente antes de aplicar. El supernet por default es `10.105.0.0/16`.
- **`managment-outbound`** sale por IGW (la interfaz de gestión del FortiGate necesita EIP). Si se prefiere NAT/FortiGate, cambiar el tier `mgmt` en `locals.tf`.
- Nombres de subnet con los tiers estándar de un despliegue FortiGate HA (`wan`/`lan`/`ha`/`mgmt`/`attachment`), incluyendo el typo `managment` (así lo usa la convención de naming de referencia — corregirlo si el cliente lo prefiere).
- No incluye: VPC endpoints, flow logs, NACLs custom, ni rango on-prem (completar cuando el cliente lo confirme).
- Las AZ se fijan por AZ ID (`sae1-az1`, `sae1-az2` en el ejemplo — ajustar al código de región real), no por nombre, porque el nombre de una AZ no mapea a la misma AZ física en cada cuenta.

## State remoto

Ver `backend.tf`. Bucket S3 con versionado, cifrado KMS/SSE, Block Public Access y `use_lockfile = true`. Migrar con `terraform init -migrate-state`.

## Prueba de conectividad

[`tests/connectivity/`](tests/connectivity/) — stack descartable que levanta una instancia en Prod y otra en Networking y prueba ping + TCP/22 entre ambas a través del TGW/FortiGate. State propio, separado de la red; `terraform destroy` al terminar.
