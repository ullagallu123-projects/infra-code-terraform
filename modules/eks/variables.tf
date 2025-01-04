# Kubernetes Cluster Version
variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
}

# VPC Configuration
variable "vpc_id" {
  description = "VPC ID where the EKS cluster and workers will be deployed"
  type        = string
}

# Subnet Configuration
variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}

# Node Group Configuration
variable "node_groups" {
  description = "Map of node group configurations"
  type = map(object({
    instance_types = list(string)
    capacity_type  = string
    scaling_config = object({
      desired_size = number
      max_size     = number
      min_size     = number
    })
  }))
}

# Allowed CIDRs for Public Access
variable "allowed_public_cidrs" {
  description = "List of CIDR blocks allowed to access the cluster publicly"
  type        = list(string)
  default     = []
}

# Environment Name
variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

# Project Name
variable "project_name" {
  description = "Project name for tagging and resource identification"
  type        = string
}

variable "common_tags" {
  description = "A map of common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "add_ons" {}
