# Prueba de conectividad Prod <-> Networking a través del TGW.
# Stack descartable: se destruye al terminar (terraform destroy). State propio, separado de la red.
#
# Resultado: cada instancia hace ping + TCP/22 contra la otra desde user-data y lo deja en la consola de EC2:
#   aws ec2 get-console-output --instance-id <id> --latest --output text

terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.60, < 7.0"
    }
  }

  backend "s3" {
    bucket       = "<cliente>-tfstate-<account-id-shared-services>-<home-region>"
    key          = "networking-test/terraform.tfstate"
    region       = "<home-region>"
    encrypt      = true
    use_lockfile = true

    assume_role = {
      role_arn = "arn:aws:iam::<account-id-shared-services>:role/AWSControlTowerExecution"
    }
  }
}

variable "network_account_id" {
  type    = string
  default = "<account-id-networking>"
}

variable "prod_account_id" {
  type    = string
  default = "<account-id-workloads-prod>"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

locals {
  # IPs fijas para que cada instancia conozca a la otra desde el user-data
  network_ip = "10.105.1.10"  # subnet lan AZ1 de Networking (10.105.1.0/27)
  prod_ip    = "10.105.10.40" # subnet db AZ1 de Prod (10.105.10.32/27)

  tags = { Cliente = "<cliente>", ManagedBy = "Terraform", Stack = "connectivity-test" }
}

provider "aws" {
  alias  = "network"
  region = "<home-region>"

  assume_role {
    role_arn = "arn:aws:iam::${var.network_account_id}:role/AWSControlTowerExecution"
  }

  default_tags {
    tags = local.tags
  }
}

provider "aws" {
  alias  = "prod"
  region = "<home-region>"

  assume_role {
    role_arn = "arn:aws:iam::${var.prod_account_id}:role/AWSControlTowerExecution"
  }

  default_tags {
    tags = local.tags
  }
}

# ------------------------------------------------------------------ Lookups (por tag Name, creadas por el stack de red)

data "aws_subnet" "network_lan" {
  provider = aws.network

  filter {
    name   = "tag:Name"
    values = ["subnet_<home-region>_az1_networking_lan"]
  }
}

data "aws_subnet" "prod_db" {
  provider = aws.prod

  filter {
    name   = "tag:Name"
    values = ["subnet_<home-region>_az1_workloads-prod_db"]
  }
}

data "aws_ssm_parameter" "al2023_network" {
  provider = aws.network
  name     = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

data "aws_ssm_parameter" "al2023_prod" {
  provider = aws.prod
  name     = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# ------------------------------------------------------------------ Security groups

resource "aws_security_group" "network" {
  provider = aws.network

  name        = "sg_test-connectivity_networking"
  description = "Prueba de conectividad: ICMP y TCP/22 desde Prod"
  vpc_id      = data.aws_subnet.network_lan.vpc_id

  tags = { Name = "sg_test-connectivity_networking" }
}

resource "aws_vpc_security_group_ingress_rule" "network_icmp" {
  provider = aws.network

  security_group_id = aws_security_group.network.id
  cidr_ipv4         = "10.105.10.0/23"
  ip_protocol       = "icmp"
  from_port         = -1
  to_port           = -1
}

resource "aws_vpc_security_group_ingress_rule" "network_ssh" {
  provider = aws.network

  security_group_id = aws_security_group.network.id
  cidr_ipv4         = "10.105.10.0/23"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "network_all" {
  provider = aws.network

  security_group_id = aws_security_group.network.id
  cidr_ipv4         = "10.105.0.0/16"
  ip_protocol       = "-1"
}

resource "aws_security_group" "prod" {
  provider = aws.prod

  name        = "sg_test-connectivity_prod"
  description = "Prueba de conectividad: ICMP y TCP/22 desde Networking"
  vpc_id      = data.aws_subnet.prod_db.vpc_id

  tags = { Name = "sg_test-connectivity_prod" }
}

resource "aws_vpc_security_group_ingress_rule" "prod_icmp" {
  provider = aws.prod

  security_group_id = aws_security_group.prod.id
  cidr_ipv4         = "10.105.0.0/21"
  ip_protocol       = "icmp"
  from_port         = -1
  to_port           = -1
}

resource "aws_vpc_security_group_ingress_rule" "prod_ssh" {
  provider = aws.prod

  security_group_id = aws_security_group.prod.id
  cidr_ipv4         = "10.105.0.0/21"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "prod_all" {
  provider = aws.prod

  security_group_id = aws_security_group.prod.id
  cidr_ipv4         = "10.105.0.0/16"
  ip_protocol       = "-1"
}

# ------------------------------------------------------------------ Instancias

locals {
  tests = {
    prod    = { from = "Prod", to = "Networking", peer = local.network_ip }
    network = { from = "Networking", to = "Prod", peer = local.prod_ip }
  }

  user_data = {
    for k, v in local.tests : k => join("\n", [
      "#!/bin/bash",
      "exec > >(tee /dev/console) 2>&1",
      "echo '=== TEST CONECTIVIDAD ${v.from} -> ${v.to} (${v.peer}) ==='",
      "for i in 1 2 3 4 5 6 7 8; do",
      "  echo \"--- intento $i $(date -u +%T)\"",
      "  if ping -c 3 -W 2 ${v.peer}; then echo 'RESULT PING_OK'; else echo 'RESULT PING_FAIL'; fi",
      "  if timeout 3 bash -c '</dev/tcp/${v.peer}/22'; then echo 'RESULT TCP22_OK'; else echo 'RESULT TCP22_FAIL'; fi",
      "  sleep 20",
      "done",
      "echo '=== FIN TEST ${v.from} -> ${v.to} ==='",
    ])
  }
}

resource "aws_instance" "network" {
  provider = aws.network

  ami                         = data.aws_ssm_parameter.al2023_network.value
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnet.network_lan.id
  private_ip                  = local.network_ip
  vpc_security_group_ids      = [aws_security_group.network.id]
  associate_public_ip_address = false
  user_data                   = local.user_data["network"]

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = { Name = "ec2_<home-region>_az1_networking_test-connectivity" }
}

resource "aws_instance" "prod" {
  provider = aws.prod

  ami                         = data.aws_ssm_parameter.al2023_prod.value
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnet.prod_db.id
  private_ip                  = local.prod_ip
  vpc_security_group_ids      = [aws_security_group.prod.id]
  associate_public_ip_address = false
  user_data                   = local.user_data["prod"]

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = { Name = "ec2_<home-region>_az1_workloads-prod_test-connectivity" }
}

output "instance_ids" {
  value = {
    network = aws_instance.network.id
    prod    = aws_instance.prod.id
  }
}
