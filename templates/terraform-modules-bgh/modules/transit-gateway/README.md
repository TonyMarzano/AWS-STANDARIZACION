# Módulo `transit-gateway`

Crea el Transit Gateway central de la arquitectura de red de referencia, con una única route table (compartida por todos los attachments) y lo comparte vía AWS RAM con las cuentas spoke. Se despliega **una sola vez, en la cuenta Networking**.

Ver el diseño completo de ruteo en [`docs/03-workloads/05-arquitectura-red-referencia.md`](../../../docs/03-workloads/05-arquitectura-red-referencia.md).

## Uso

```hcl
module "transit_gateway" {
  source = "git::https://github.com/<org-bgh>/terraform-modules-bgh.git//modules/transit-gateway?ref=v1.0.0"

  name              = "cliente-tgw"
  spoke_account_ids = [
    "111111111111", # Workloads Prod
    "222222222222", # Workloads Dev
  ]
}
```

## Después de aplicar

Cada cuenta spoke debe **aceptar la invitación de RAM** antes de poder crear su `tgw-attachment` (una vez, manual o scripteado):

```powershell
$ShareArn = (terraform output -raw ram_resource_share_arn)  # desde la cuenta Networking
aws ram get-resource-share-invitations --resource-share-arns $ShareArn --profile <perfil-cuenta-spoke>
aws ram accept-resource-share-invitation --resource-share-invitation-arn <arn-de-la-invitación> --profile <perfil-cuenta-spoke>
```

La ruta estática default (`0.0.0.0/0` → attachment de Networking) no la crea este módulo — se agrega desde `envs/networking/network/main.tf`, después de crear el attachment de la VPC de Networking, para evitar una dependencia circular entre el Transit Gateway y su propio attachment.
