# modules/gateway/main.tf
resource "aws_internet_gateway" "this" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

resource "aws_eip" "nat" {
  for_each = var.public_subnet_ids
  # vpc      = true
  tags = {
    Name = "${var.vpc_name}-eip-${each.key}"
  }
}

resource "aws_nat_gateway" "this" {
  for_each      = var.public_subnet_ids
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value

  tags = {
    Name = "${var.vpc_name}-natgw-${each.key}"
  }
}
