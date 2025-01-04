resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    {
    Name        = "${local.name}-public"
    },
    var.common_tags
  )
}

resource "aws_route_table" "private" {
  for_each = var.nat_gateway_configuration == "single" ? tomap({ "single" = "single" }) : tomap({ for k, v in local.azs_map : k => v.az_suffix })  # Extract only the az_suffix or any string value

  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = var.nat_gateway_configuration == "none" ? [] : [1]
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = var.nat_gateway_configuration == "single" ? aws_nat_gateway.main["single"].id : aws_nat_gateway.main[each.key].id
    }
  }

  tags = merge(
    {
      Name = var.nat_gateway_configuration == "single" || var.nat_gateway_configuration == "none" ? "${local.name}-private" : "${local.name}-private-${each.value}"
    },
    var.common_tags
  )
}

resource "aws_route_table" "database" {
  for_each = var.nat_gateway_configuration == "single" ? tomap({ "single" = "single" }) : tomap({ for k, v in local.azs_map : k => v.az_suffix })  # Extract only the az_suffix or any string value

  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = var.nat_gateway_configuration == "none" ? [] : [1]
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = var.nat_gateway_configuration == "single" ? aws_nat_gateway.main["single"].id : aws_nat_gateway.main[each.key].id
    }
  }

  tags = merge(
    {
      Name = var.nat_gateway_configuration == "single" || var.nat_gateway_configuration == "none" ? "${local.name}-database" : "${local.name}-database-${each.value}"
    },
    var.common_tags
  )
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  for_each       = local.azs_map
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  for_each       = local.azs_map
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = var.nat_gateway_configuration == "single" ? aws_route_table.private["single"].id : aws_route_table.private[each.key].id
}

resource "aws_route_table_association" "database" {
  for_each       = local.azs_map
  subnet_id      = aws_subnet.database[each.key].id
  route_table_id = var.nat_gateway_configuration == "single" ? aws_route_table.database["single"].id : aws_route_table.database[each.key].id
}


