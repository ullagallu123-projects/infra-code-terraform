### VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(
    var.common_tags,
    {
      Name = local.name
    },
    var.enable_kubernetes_k8s_tags ? {"kubernetes.io/cluster/${var.environment}-${var.project_name}" = "shared"} : {}
  )
}
### Flow Logs
resource "aws_cloudwatch_log_group" "vpc_log_group" {
  count             = var.enable_vpc_flow_logs ? 1 : 0
  name              = "vpc-flow-logs"
  retention_in_days = 7
}

resource "aws_iam_role" "vpc_flow_log_role" {
  count = var.enable_vpc_flow_logs ? 1 : 0
  name  = "vpcFlowLogRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "vpc_flow_log_policy" {
  count = var.enable_vpc_flow_logs ? 1 : 0
  role  = aws_iam_role.vpc_flow_log_role[0].id
  name = "${local.name}-vpc-flow-cw"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Effect   = "Allow"
      Resource = "${aws_cloudwatch_log_group.vpc_log_group[0].arn}:*"
    }]
  })
}

resource "aws_flow_log" "vpc_flow_logs" {
  count                = var.enable_vpc_flow_logs ? 1 : 0
  log_destination      = aws_cloudwatch_log_group.vpc_log_group[0].arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id
  iam_role_arn         = aws_iam_role.vpc_flow_log_role[0].arn
  tags = merge(
    {
      Name = local.name
    },
    var.common_tags
  )
}












