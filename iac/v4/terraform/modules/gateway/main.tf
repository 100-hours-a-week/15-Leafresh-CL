# modules/gateway/main.tf

locals {
  public_rt_assocs = merge([
    for az, subs in var.public_subnet_ids : {
      for idx, sn in subs :
      # build a key "az-index"  →  an object with subnet_id & rt_id
      "${az}-${idx}" => {
        subnet_id = sn
        rt_id     = aws_route_table.public[az].id
      }
    }
  ]...)

    private_rt_assocs = merge([
    for az, subs in var.private_subnet_ids : {
      for idx, sn in subs :
      "${az}-${idx}" => {
        subnet_id = sn
        rt_id     = aws_route_table.private[az].id
      }
    }
  ]...)
}


# 1) Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

# 2) EIP for each AZ (public subnet)
resource "aws_eip" "nat" {
  for_each = var.public_subnet_ids#

  tags = {
    Name = "${var.vpc_name}-eip-${each.key}"
  }
}

# 3) NAT Gateway in each public subnet
resource "aws_nat_gateway" "this" {
  for_each      = var.public_subnet_ids
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value

  tags = {
    Name = "${var.vpc_name}-natgw-${each.key}"
  }

  depends_on = [aws_internet_gateway.this]
}

# 4) Public route tables → IGW
resource "aws_route_table" "public" {
  for_each = var.public_subnet_ids
  vpc_id   = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.vpc_name}-rt-public-${each.key}"
  }
}

# 5) Private route tables → NAT Gateway
resource "aws_route_table" "private" {
  for_each = var.private_subnet_ids
  vpc_id   = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id         = aws_nat_gateway.this[each.key].id
  }

  tags = {
    Name = "${var.vpc_name}-rt-private-${each.key}"
  }
}

resource "aws_route_table_association" "public" {
  for_each       = local.public_rt_assocs
  subnet_id      = each.value.subnet_id
  route_table_id = each.value.rt_id
}

resource "aws_route_table_association" "private" {
  for_each       = local.private_rt_assocs
  subnet_id      = each.value.subnet_id
  route_table_id = each.value.rt_id
}
