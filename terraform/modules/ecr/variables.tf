variable "repository_name" {
  description = "ECR repository name"
  type        = string
}

variable "image_tag_mutability" {
  description = "MUTABLE or IMMUTABLE"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

variable "max_image_count" {
  description = "Number of images to retain via lifecycle policy"
  type        = number
  default     = 10
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
