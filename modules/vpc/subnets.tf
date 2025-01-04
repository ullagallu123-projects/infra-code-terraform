### Public Subnets
resource "aws_subnet" "public" {
  for_each          = local.azs_map
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.public_cidr
  availability_zone = each.value.az

  map_public_ip_on_launch = true

  tags = merge (
    {
        Name        = "${local.name}-public-${each.value.az_suffix}"
    },
    var.enable_kubernetes_k8s_tags ? {
      "kubernetes.io/cluster/${var.environment}-eks" = "shared"
      "kubernetes.io/role/elb" = 1 } : {},
    var.common_tags
  )
}

### Private Subnets
resource "aws_subnet" "private" {
  for_each          = local.azs_map
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.private_cidr
  availability_zone = each.value.az
  tags = merge (
    {
        Name        = "${local.name}-private-${each.value.az_suffix}"
    },
    var.enable_kubernetes_k8s_tags ? {
      "kubernetes.io/cluster/${var.environment}-eks" = "shared"
      "kubernetes.io/role/elb" = 1 } : {},
    var.common_tags
  )
}

### DB subnets
resource "aws_subnet" "database" {
  for_each          = local.azs_map
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.database_cidr
  availability_zone = each.value.az
  tags = merge(
    {
     Name        = "${local.name}-database-${each.value.az_suffix}"
    },
    var.enable_kubernetes_k8s_tags ? 
      {"kubernetes.io/cluster/${var.environment}-eks" = "shared"} : {},
    var.common_tags
  )
}

### DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name        = "${local.name}"
  description = "Database subnet group for ${local.name}"
  subnet_ids  = [for subnet in aws_subnet.database : subnet.id]

  tags = merge(
       {
        Name        = local.name
       },
       var.common_tags
  )
}