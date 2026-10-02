resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = var.name }
}

# --- Subnets privadas (una por AZ) ---

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = { Name = "${var.name}-private-${var.azs[count.index]}" }
}

resource "aws_route_table" "private" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.this.id

  tags = { Name = "${var.name}-private-rt-${var.azs[count.index]}" }
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# --- Subnets públicas (opcionales) ---

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = { Name = "${var.name}-public-${var.azs[count.index]}" }
}

resource "aws_internet_gateway" "this" {
  count  = length(var.public_subnet_cidrs) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = { Name = "${var.name}-igw" }
}

resource "aws_route_table" "public" {
  count  = length(var.public_subnet_cidrs)
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this[0].id
  }

  tags = { Name = "${var.name}-public-rt-${var.azs[count.index]}" }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}

# --- NAT Gateway por AZ (opcional) ---

resource "aws_eip" "nat" {
  count  = var.enable_nat ? length(var.public_subnet_cidrs) : 0
  domain = "vpc"

  tags = { Name = "${var.name}-nat-eip-${var.azs[count.index]}" }
}

resource "aws_nat_gateway" "this" {
  count         = var.enable_nat ? length(var.public_subnet_cidrs) : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = { Name = "${var.name}-nat-${var.azs[count.index]}" }
}

resource "aws_route" "private_to_nat" {
  count                  = var.enable_nat ? length(var.private_subnet_cidrs) : 0
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[count.index].id
}

# --- Subnets dedicadas al attachment del Transit Gateway (opcionales) ---

resource "aws_subnet" "tgw" {
  count             = length(var.tgw_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.tgw_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = { Name = "${var.name}-tgw-attach-${var.azs[count.index]}" }
}

resource "aws_route_table" "tgw" {
  count  = length(var.tgw_subnet_cidrs)
  vpc_id = aws_vpc.this.id

  tags = { Name = "${var.name}-tgw-attach-rt-${var.azs[count.index]}" }
}

resource "aws_route_table_association" "tgw" {
  count          = length(var.tgw_subnet_cidrs)
  subnet_id      = aws_subnet.tgw[count.index].id
  route_table_id = aws_route_table.tgw[count.index].id
}
