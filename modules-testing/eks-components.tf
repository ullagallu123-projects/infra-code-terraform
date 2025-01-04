### VPC
module "vpc" {
  source                     = "../modules/vpc"
  vpc_cidr                   = "192.168.0.0/16"
  environment                = var.environment
  project_name               = var.project_name
  azs                        = ["ap-south-1a", "ap-south-1b"]
  public_subnet_cidrs        = ["192.168.1.0/24", "192.168.2.0/24"]
  private_subnet_cidrs       = ["192.168.11.0/24", "192.168.12.0/24"]
  database_subnet_cidrs      = ["192.168.21.0/24", "192.168.22.0/24"]
  nat_gateway_configuration  = "none"
  enable_vpc_flow_logs       = true
  enable_kubernetes_k8s_tags = true
  common_tags = {
    Developer = "Sivaramakrishna"
    Terraform = true
  }
}

module "eks" {
  depends_on           = [module.vpc]
  source               = "../modules/eks"
  environment          = var.environment
  project_name         = var.project_name
  cluster_version      = "1.30"
  vpc_id               = module.vpc.vpc_id
  subnet_ids           = module.vpc.public_subnet_ids
  allowed_public_cidrs = ["0.0.0.0/0"]
  add_ons = {
    vpc-cni                = "v1.19.2-eksbuild.1"
    kube-proxy             = "v1.30.3-eksbuild.2"
    coredns                = "v1.11.4-eksbuild.1"
    eks-pod-identity-agent = "v1.3.4-eksbuild.1"
  }

  node_groups = {
    ng-1 = {
      instance_types = ["t3a.small"]
      capacity_type  = "ON_DEMAND"
      scaling_config = {
        desired_size = 2
        max_size     = 4
        min_size     = 0
      }
    }
  }
}

# SPOT
# ON_DEMAND