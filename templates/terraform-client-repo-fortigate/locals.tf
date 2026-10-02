# Diseño de red tomado del relevamiento de red del cliente (Excel/intake). Cambios de CIDR/nombres
# se hacen acá.
#
# Las AZ se referencian por AZ ID (no por nombre): el nombre "sa-east-1a" mapea a una AZ física
# distinta en cada cuenta, y los TGW attachments de todas las cuentas tienen que caer en las mismas AZ.

locals {
  az_ids = {
    az1 = "sae1-az1"
    az2 = "sae1-az2"
  }

  # Spokes: todo lo que sale de una subnet de workload va al TGW (0.0.0.0/0), que lo manda a inspección.
  # La subnet de attachment queda solo con la ruta local.
  spoke_tiers = {
    attachment    = {}
    db            = { tgw_cidrs = ["0.0.0.0/0"] }
    vpc_endpoints = { tgw_cidrs = ["0.0.0.0/0"] }
  }

  vpcs = {
    # ---------------------------------------------------------------- Networking (10.105.0.0/21)
    networking = {
      name = "vpc_${var.region}_networking"
      cidr = "10.105.0.0/21"
      subnets = {
        az1_wan        = { tier = "wan", az = "az1", name = "subnet_${var.region}_az1_networking_wan", cidr = "10.105.0.0/24" }
        az1_lan        = { tier = "lan", az = "az1", name = "subnet_${var.region}_az1_networking_lan", cidr = "10.105.1.0/27" }
        az1_ha         = { tier = "ha", az = "az1", name = "subnet_${var.region}_az1_networking_ha", cidr = "10.105.1.32/27" }
        az1_mgmt       = { tier = "mgmt", az = "az1", name = "subnet_${var.region}_az1_networking_managment-outbound", cidr = "10.105.1.64/27" }
        az1_attachment = { tier = "attachment", az = "az1", name = "subnet_${var.region}_az1_networking_attachment-tg", cidr = "10.105.1.96/28" }

        az2_wan        = { tier = "wan", az = "az2", name = "subnet_${var.region}_az2_networking_wan", cidr = "10.105.4.0/24" }
        az2_lan        = { tier = "lan", az = "az2", name = "subnet_${var.region}_az2_networking_lan", cidr = "10.105.5.0/27" }
        az2_ha         = { tier = "ha", az = "az2", name = "subnet_${var.region}_az2_networking_ha", cidr = "10.105.5.32/27" }
        az2_mgmt       = { tier = "mgmt", az = "az2", name = "subnet_${var.region}_az2_networking_managment-outbound", cidr = "10.105.5.64/27" }
        az2_attachment = { tier = "attachment", az = "az2", name = "subnet_${var.region}_az2_networking_attachment-tg", cidr = "10.105.5.96/28" }
      }
      tiers = {
        wan        = { igw_cidrs = ["0.0.0.0/0"] }       # WAN FortiGate: salida a Internet + terminación VPN
        lan        = { tgw_cidrs = [var.supernet_cidr] } # retorno hacia los spokes (post-inspección)
        ha         = {}                                  # heartbeat/sync del cluster: solo ruta local
        mgmt       = { igw_cidrs = ["0.0.0.0/0"] }       # outbound de gestión (licencias, FortiGuard)
        attachment = {}                                  # 0.0.0.0/0 -> ENI LAN del FortiGate (var.fortigate_lan_eni_ids)
      }
    }

    # ---------------------------------------------------------------- Shared (10.105.8.0/23)
    # Solo se crean las subnets de attachment para que la VPC quede conectada al TGW.
    # TODO: definir las subnets de servicios compartidos del cliente.
    shared = {
      name = "vpc_${var.region}_shared"
      cidr = "10.105.8.0/23"
      subnets = {
        az1_attachment = { tier = "attachment", az = "az1", name = "subnet_${var.region}_az1_shared_attachment-tg", cidr = "10.105.8.0/28" }
        az2_attachment = { tier = "attachment", az = "az2", name = "subnet_${var.region}_az2_shared_attachment-tg", cidr = "10.105.9.0/28" }
      }
      tiers = {
        attachment = {}
      }
    }

    # ---------------------------------------------------------------- Workload Prod (10.105.10.0/23)
    workloads_prod = {
      name = "vpc_${var.region}_prod_workloads"
      cidr = "10.105.10.0/23"
      subnets = {
        az1_attachment    = { tier = "attachment", az = "az1", name = "subnet_${var.region}_az1_workloads-prod_attachment-tg", cidr = "10.105.10.0/28" }
        az1_db            = { tier = "db", az = "az1", name = "subnet_${var.region}_az1_workloads-prod_db", cidr = "10.105.10.32/27" }
        az1_vpc_endpoints = { tier = "vpc_endpoints", az = "az1", name = "subnet_${var.region}_az1_workloads-prod_vpc-endpoints", cidr = "10.105.10.16/28" }

        az2_attachment    = { tier = "attachment", az = "az2", name = "subnet_${var.region}_az2_workloads-prod_attachment-tg", cidr = "10.105.11.0/28" }
        az2_db            = { tier = "db", az = "az2", name = "subnet_${var.region}_az2_workloads-prod_db", cidr = "10.105.11.32/27" }
        az2_vpc_endpoints = { tier = "vpc_endpoints", az = "az2", name = "subnet_${var.region}_az2_workloads-prod_vpc-endpoints", cidr = "10.105.11.16/28" }
      }
      tiers = local.spoke_tiers
    }

    # ---------------------------------------------------------------- Workload QA (10.105.12.0/23)
    workloads_qa = {
      name = "vpc_${var.region}_qa_workloads"
      cidr = "10.105.12.0/23"
      subnets = {
        az1_attachment    = { tier = "attachment", az = "az1", name = "subnet_${var.region}_az1_workloads-qa_attachment-tg", cidr = "10.105.12.0/28" }
        az1_db            = { tier = "db", az = "az1", name = "subnet_${var.region}_az1_workloads-qa_db", cidr = "10.105.12.32/27" }
        az1_vpc_endpoints = { tier = "vpc_endpoints", az = "az1", name = "subnet_${var.region}_az1_workloads-qa_vpc-endpoints", cidr = "10.105.12.16/28" }

        az2_attachment    = { tier = "attachment", az = "az2", name = "subnet_${var.region}_az2_workloads-qa_attachment-tg", cidr = "10.105.13.0/28" }
        az2_db            = { tier = "db", az = "az2", name = "subnet_${var.region}_az2_workloads-qa_db", cidr = "10.105.13.32/27" }
        az2_vpc_endpoints = { tier = "vpc_endpoints", az = "az2", name = "subnet_${var.region}_az2_workloads-qa_vpc-endpoints", cidr = "10.105.13.16/28" }
      }
      tiers = local.spoke_tiers
    }
  }

  # Agrega el AZ ID a cada subnet
  subnets = {
    for vk, v in local.vpcs : vk => {
      for sk, s in v.subnets : sk => merge(s, { az_id = local.az_ids[s.az] })
    }
  }
}
