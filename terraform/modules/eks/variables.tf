variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.30"
}

variable "subnet_ids" {
  description = "Subnet IDs for the EKS cluster (private + public)"
  type        = list(string)
}

variable "node_subnet_ids" {
  description = "Subnet IDs where node groups are placed (private)"
  type        = list(string)
}

variable "node_instance_types" {
  description = "EC2 instance types for the managed node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired node count"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum node count"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum node count"
  type        = number
  default     = 3
}

variable "node_disk_size" {
  description = "Node EBS volume size in GiB"
  type        = number
  default     = 20
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
