# Changelog — terraform-modules-bgh

## v1.0.0 (al crear el repo real)

- `vpc`: VPC genérica (privada/pública/NAT/tgw-attach opcionales).
- `transit-gateway`: Transit Gateway + route table compartida + RAM share.
- `tgw-attachment`: attachment genérico con asociación/propagación explícita.

Primer set de módulos: arquitectura de referencia de red con egress centralizado vía Transit Gateway (ver `docs/03-workloads/05-arquitectura-red-referencia.md`).
