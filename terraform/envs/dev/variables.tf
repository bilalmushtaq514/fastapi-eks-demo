variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project name (used as prefix)"
  type        = string
  default     = "microservice"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones (length 2)"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.30"
}

variable "node_instance_types" {
  description = "Node instance types"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired node count"
  type        = number
  default     = 2
}

variable "github_owner" {
  description = "GitHub org/user that owns the repo"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_ref_patterns" {
  description = "Allowed GitHub OIDC subject patterns"
  type        = list(string)
  default     = ["ref:refs/heads/main"]
}

variable "create_github_oidc_provider" {
  description = "Create the GitHub OIDC provider (set false if it already exists in this AWS account)"
  type        = bool
  default     = true
}
