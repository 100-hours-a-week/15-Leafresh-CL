# modules/subnets/main.tf
# modules/subnets/main.tf
resource "aws_subnet" "this" {
  for_each = toset(var.availability_zones)
  vpc_id   = var.vpc_id
  # Reverting cidr_block calculation to use `var.base_az_cidr_block`
  cidr_block = cidrsubnet(
    var.base_az_cidr_block[each.value],                                              # This will be the /19 for the AZ
    var.prefix_length - tonumber(split("/", var.base_az_cidr_block[each.value])[1]), # This is the "newbits" (e.g., 22-19 = 3)
    var.offset                                                                       # This is the offset within the /19 AZ block
  )
  availability_zone       = each.value
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge({
    Name = "${var.name_prefix}-${each.value}"
  }, var.additional_tags)
}

resource "aws_route_table" "this" {
  for_each = var.needs_route_table ? toset(var.availability_zones) : toset([])
  vpc_id   = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.is_public ? var.internet_gateway_id : var.nat_gateway_ids[each.value]
  }

  tags = {
    Name = "${var.name_prefix}-rt-${each.value}"
  }
}

resource "aws_route_table_association" "this" {
  for_each       = var.needs_route_table ? aws_subnet.this : {}
  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.this[each.key].id
}
