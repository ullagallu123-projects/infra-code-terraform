### IGW
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = local.name
    }
  )
}

### Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  for_each = var.nat_gateway_configuration == "none" ? {} : (
    var.nat_gateway_configuration == "single" ? tomap({ "single" = "single" }) : tomap({ for k, v in local.azs_map : k => v.az_suffix })
  )
  domain = "vpc"

  tags = {
    Name        = var.nat_gateway_configuration == "single" ? "${local.name}-eip-single" : "${local.name}-eip-${each.value}"
    Environment = var.environment
  }
}

### NAT Gateways
resource "aws_nat_gateway" "main" {
  for_each = var.nat_gateway_configuration == "none" ? {} : (
    var.nat_gateway_configuration == "single" ? tomap({ "single" = "single" }) : tomap({ for k, v in local.azs_map : k => v.az_suffix })
  )

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = var.nat_gateway_configuration == "single" ? values(aws_subnet.public)[0].id : aws_subnet.public[each.key].id

  tags = {
    Name        = var.nat_gateway_configuration == "single" ? "${local.name}-nat-single" : "${local.name}-nat-${each.value}"
    Environment = var.environment
  }

  depends_on = [aws_internet_gateway.main]
}
