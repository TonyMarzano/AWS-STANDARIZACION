# Arquitectura de red — variante con FortiGate

Variante de [`05-arquitectura-red-referencia.md`](05-arquitectura-red-referencia.md) para cuando el cliente necesita (o ya tiene) **inspección de tráfico con FortiGate**, no solo egress centralizado. Mismo principio de fondo — un Transit Gateway centraliza el tráfico en la cuenta Networking — pero acá **todo** el tráfico de los spokes (Internet, on-prem, y spoke↔spoke) pasa por el firewall, no solo la salida a Internet.

Skeleton: [`templates/terraform-client-repo-fortigate/`](../../templates/terraform-client-repo-fortigate/) (alternativa a [`templates/terraform-client-repo/`](../../templates/terraform-client-repo/) — copiar **uno de los dos**, no ambos, según si el cliente necesita FortiGate).

## Cuál opción usar

| | [`terraform-client-repo/`](../../templates/terraform-client-repo/) | [`terraform-client-repo-fortigate/`](../../templates/terraform-client-repo-fortigate/) |
|---|---|---|
| Cuándo | Cliente sin appliance de inspección | Cliente con (o va a tener) FortiGate |
| Qué pasa por Networking | Solo tráfico a Internet | Todo: Internet, on-prem, spoke↔spoke |
| Spoke↔spoke | Directo por el TGW | Vía FortiGate (inspeccionado) |
| Mecanismo de ruteo | 1 TGW route table compartida + ruta estática | 2 TGW route tables (`rt_spokes` / `rt_inspection`) |
| Cuentas | Networking, Prod, Dev | Networking, Shared, Prod, QA |
| Appliance | Ninguno | FortiGate (ENI LAN como next-hop, no GWLB) |

Ambas comparten la misma idea de diseño (Transit Gateway + centralización en Networking, route tables asociadas/propagadas explícitamente, nunca por default) — difieren en si existe o no un punto de inspección obligatorio.

## Por qué ENI routing y no Gateway Load Balancer

A diferencia de lo que se evaluó inicialmente para este repo (ver historial de `05-arquitectura-red-referencia.md`), esta variante **no usa GWLB**: rutea directo a la ENI de la interfaz LAN del FortiGate (`var.fortigate_lan_eni_ids`). Es más simple de operar para un par de FortiGate en HA activo/pasivo (el caso más común en una PyME/empresa mediana) — no hace falta un Gateway Load Balancer ni su target group cuando hay un solo firewall activo a la vez. GWLB vale la pena recién cuando hay múltiples instancias de firewall detrás de un balanceador (escala horizontal real); si ese es el caso del cliente, evaluarlo como una variante aparte en vez de forzarlo acá.

## Topología

```
 Shared / Prod / QA (spokes)                    Networking
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

Los spokes **no propagan entre sí** — por eso no se ven directo, todo pasa por el FortiGate.

## Diseño de subnets (data-driven, por tiers)

A diferencia del módulo `vpc` simple de la variante sin FortiGate, acá cada VPC se define declarativamente en `locals.tf` como un mapa de subnets + un mapa de `tiers` (política de ruteo por tier: a qué CIDRs apunta cada tier hacia IGW y/o TGW). El módulo [`modules/vpc`](../../templates/terraform-client-repo-fortigate/modules/vpc/) interpreta esos mapas y genera subnets + route tables + rutas automáticamente — agregar una subnet nueva es agregar una entrada al mapa, no escribir recursos a mano.

Tiers de la VPC de Networking (los que importan para el FortiGate):

| Tier | Rutas | Para qué |
|---|---|---|
| `wan` | `0.0.0.0/0` → IGW | Interfaz WAN del FortiGate: Internet + terminación VPN |
| `lan` | supernet del cliente → TGW | Retorno hacia los spokes, post-inspección |
| `ha` | solo local | Heartbeat/sync del cluster FortiGate |
| `mgmt` | `0.0.0.0/0` → IGW | Outbound de gestión (licencias, FortiGuard) |
| `attachment` | `0.0.0.0/0` → ENI LAN del FortiGate | Acá entra el tráfico que viene del TGW, directo al firewall |

## Uso

1. Copiar [`templates/terraform-client-repo-fortigate/`](../../templates/terraform-client-repo-fortigate/) como raíz del repo `tf-<cliente>` (en vez de `terraform-client-repo/`).
2. Ajustar `locals.tf` con el CIDR plan real del cliente (el que trae por default es un ejemplo de referencia).
3. `cp terraform.tfvars.example terraform.tfvars` y completar `cliente` + account IDs.
4. Desplegar la red (`terraform apply`) — el FortiGate **no** se despliega acá, queda con `fortigate_lan_eni_ids = {}` (ver siguiente paso).
5. Desplegar las instancias de FortiGate por separado (AMI de AWS Marketplace, HA activo/pasivo en las subnets `ha`/`wan`/`lan`/`mgmt`) — ver el repo oficial de Fortinet, [`fortigate-terraform-deploy`](https://github.com/fortinet/fortigate-terraform-deploy), como referencia de despliegue del appliance en sí.
6. Una vez desplegado, pasar las ENI LAN reales en `fortigate_lan_eni_ids` (`terraform.tfvars`) y re-aplicar — recién ahí el tráfico empieza a pasar por inspección.
7. Validar con el stack descartable de [`tests/connectivity/`](../../templates/terraform-client-repo-fortigate/tests/connectivity/).

## Registro

Mismos campos que la variante sin FortiGate (ver `05-arquitectura-red-referencia.md` → Registro), más: Account ID de Shared, CIDRs de Prod/QA, y fecha en que se pasaron las `fortigate_lan_eni_ids` reales (marca cuándo la inspección quedó realmente activa, no solo la red desplegada).

## Siguiente paso

Con la red (y el FortiGate, cuando esté) desplegados, seguí con [`04-flujo-trabajo.md`](04-flujo-trabajo.md) para el día a día de cada workload nuevo sobre esta base.
