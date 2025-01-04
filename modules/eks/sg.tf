# Security Group for EKS Cluster
resource "aws_security_group" "cluster" {
  name        = "${var.environment}-${var.project_name}"
  description = "Security group for EKS cluster"
  vpc_id      = var.vpc_id
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-${var.project_name}"
  }
}