output "region" {
  value       = var.region
  description = "AWS region"
}

output "cluster_name" {
  value       = module.eks.cluster_name
  description = "EKS cluster name (set as GH variable EKS_CLUSTER_NAME)"
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "EKS API endpoint"
}

output "ecr_repository_url" {
  value       = module.ecr.repository_url
  description = "ECR repository URL (set as GH variable ECR_REPOSITORY)"
}

output "github_actions_role_arn" {
  value       = module.iam_github_actions.role_arn
  description = "IAM role ARN for GitHub Actions OIDC (set as GH secret AWS_ROLE_ARN)"
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}
