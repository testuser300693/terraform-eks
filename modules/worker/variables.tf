variable "aws_eks_cluster_name" {
  description = ""
  type = list(string)
  # default = ""
}

variable "private_subnet_ids" {
  description = ""
  type        = list(string)
  # default     = []
}

variable "public_subnet_ids" {
  description = ""
  type        = list(string)
  # default     = []
}