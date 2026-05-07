variable "name" {
  description = "Name of the IAM role for GitHub Actions"
  type        = string
}

variable "github_owner" {
  description = "GitHub organization or user that owns the repo"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name (without owner)"
  type        = string
}

variable "github_ref_patterns" {
  description = "Allowed GitHub ref patterns (e.g. 'ref:refs/heads/main', 'environment:dev', '*')"
  type        = list(string)
  default     = ["ref:refs/heads/main"]
}

variable "ecr_repository_arn" {
  description = "ECR repository ARN this role is allowed to push to"
  type        = string
}

variable "eks_cluster_arn" {
  description = "EKS cluster ARN this role is allowed to describe/access"
  type        = string
}

variable "create_oidc_provider" {
  description = "Whether to create the GitHub OIDC provider (only one allowed per AWS account)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
