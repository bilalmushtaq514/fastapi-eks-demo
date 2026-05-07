output "cluster_name" {
  value       = aws_eks_cluster.this.name
  description = "EKS cluster name"
}

output "cluster_endpoint" {
  value       = aws_eks_cluster.this.endpoint
  description = "EKS API endpoint"
}

output "cluster_arn" {
  value       = aws_eks_cluster.this.arn
  description = "EKS cluster ARN"
}

output "cluster_certificate_authority_data" {
  value       = aws_eks_cluster.this.certificate_authority[0].data
  description = "Cluster CA data (base64)"
}

output "oidc_provider_arn" {
  value       = aws_iam_openid_connect_provider.cluster.arn
  description = "OIDC provider ARN for IRSA"
}

output "oidc_provider_url" {
  value       = aws_iam_openid_connect_provider.cluster.url
  description = "OIDC provider URL (without https://)"
}

output "node_role_arn" {
  value       = aws_iam_role.nodes.arn
  description = "Node group IAM role ARN"
}
