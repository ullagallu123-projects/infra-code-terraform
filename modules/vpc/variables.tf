# VPC and Network Configuration
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "environment" {
  description = "The environment name (e.g., dev, prod)"
  type        = string
}

variable "project_name" {
  description = "The project name"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

# Availability Zones
variable "azs" {
  description = "List of availability zones"
  type        = list(string)
  validation {
    condition     = length(var.azs) > 0
    error_message = "Please provide at least one availability zone"
  }
}

# Subnet Configuration
variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for database subnets"
  type        = list(string)
}

variable "enable_kubernetes_k8s_tags" {
  description = "Enter true or false for k8s tags for vpc and Subents"
  type = bool
}

variable "nat_gateway_configuration" {
  description = "NAT Gateway deployment configuration: 'none', 'single' or 'per_az'"
  type        = string
  default     = "none"
  validation {
    condition     = contains(["none", "single", "per_az"], var.nat_gateway_configuration)
    error_message = "nat_gateway_configuration must be one of: 'none', 'single', or 'per_az'"
  }
}

variable "enable_vpc_flow_logs" {
  description = "Enable VPC flow logs"
  type        = bool
  default     = false
}

