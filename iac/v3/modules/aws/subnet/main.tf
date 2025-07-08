# modules/subnet/main.tf

resource "aws_subnet" "public" {
  for_each                = var.public_subnet_cidrs
  vpc_id                  = var.vpc_id
  cidr_block              = each.value
  availability_zone       = "${var.region}${each.key}"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-subnet-public-${each.key}"
  }
}

# Elastic IPs for NAT
resource "aws_eip" "nat" {
  for_each = aws_subnet.public

  tags = {
    Name = "${var.project_name}-nat-eip-${each.key}"
  }
}

# NAT Gateways
resource "aws_nat_gateway" "natgw" {
  for_each      = aws_subnet.public
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value.id

  tags = {
    Name = "${var.project_name}-nat-gw-${each.key}"
  }
}

# Public route table
resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }

  tags = {
    Name = "${var.project_name}-rt-public"
  }
}

resource "aws_route_table_association" "public_assoc" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Private route tables per AZ
resource "aws_route_table" "private" {
  for_each = aws_nat_gateway.natgw
  vpc_id   = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = each.value.id
  }

  tags = {
    Name = "${var.project_name}-rt-private-${each.key}"
  }
}

# Private subnets
resource "aws_subnet" "private" {
  for_each                = var.private_subnet_cidrs
  vpc_id                  = var.vpc_id
  cidr_block              = each.value
  availability_zone       = "${var.region}${split("-", each.key)[0]}"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-subnet-private-${split("-", each.key)[0]}-${split("-", each.key)[1]}"
  }
}

resource "aws_route_table_association" "private_assoc" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[split("-", each.key)[0]].id
}