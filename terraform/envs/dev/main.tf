provider "aws" {
  region = var.region

  default_tags {
    tags = local.common_tags
  }
}

locals {
  name_prefix = "${var.project}-${var.environment}"

  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

module "vpc" {
  source = "../../modules/vpc"

  name                 = local.name_prefix
  cidr_block           = var.vpc_cidr
  azs                  = var.azs
  cluster_name         = local.name_prefix
  public_subnet_cidrs  = ["10.0.0.0/20", "10.0.16.0/20"]
  private_subnet_cidrs = ["10.0.32.0/20", "10.0.48.0/20"]

  tags = local.common_tags
}

module "ecr" {
  source = "../../modules/ecr"

  repository_name = local.name_prefix
  scan_on_push    = true
  max_image_count = 10

  tags = local.common_tags
}

module "eks" {
  source = "../../modules/eks"

  cluster_name        = local.name_prefix
  kubernetes_version  = var.kubernetes_version
  subnet_ids          = concat(module.vpc.public_subnet_ids, module.vpc.private_subnet_ids)
  node_subnet_ids     = module.vpc.private_subnet_ids
  node_instance_types = var.node_instance_types
  node_desired_size   = var.node_desired_size

  tags = local.common_tags
}

module "iam_github_actions" {
  source = "../../modules/iam"

  name                 = "${local.name_prefix}-gha"
  github_owner         = var.github_owner
  github_repo          = var.github_repo
  github_ref_patterns  = var.github_ref_patterns
  ecr_repository_arn   = module.ecr.repository_arn
  eks_cluster_arn      = module.eks.cluster_arn
  create_oidc_provider = var.create_github_oidc_provider

  tags = local.common_tags
}

# Grant the GitHub Actions role permission to authenticate to the EKS cluster
# by adding it to the aws-auth ConfigMap via an EKS access entry (requires
# cluster authentication mode "API" or "API_AND_CONFIG_MAP", default since EKS 1.30).
resource "aws_eks_access_entry" "github_actions" {
  cluster_name  = module.eks.cluster_name
  principal_arn = module.iam_github_actions.role_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "github_actions_admin" {
  cluster_name  = module.eks.cluster_name
  principal_arn = module.iam_github_actions.role_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.github_actions]
}
