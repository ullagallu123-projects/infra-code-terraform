### Locals
locals {
  name = "${var.environment}-${var.project_name}"

  # Convert az name (e.g., ap-south-1a) to suffix (e.g., 1a)
  az_suffix = { for idx, az in var.azs : 
    az => split("-", az)[2]
  }

  azs_map = { for idx, az in var.azs : 
    "${var.environment}-az-${az}" => {
      az            = az
      az_suffix     = local.az_suffix[az]
      az_index      = idx
      public_cidr   = var.public_subnet_cidrs[idx]
      private_cidr  = var.private_subnet_cidrs[idx]
      database_cidr = var.database_subnet_cidrs[idx]
    }
  }

  # Ensure consistent type for nat_gateway_map, using az_suffix (string) as value for map
  nat_gateway_map = var.nat_gateway_configuration == "none" ? tomap({}) : (
    var.nat_gateway_configuration == "single" ? 
    tomap({ "single" = "single" }) : 
    tomap({ for k, v in local.azs_map : k => v.az_suffix }) # Convert azs_map to map of strings (az_suffix)
  )
}