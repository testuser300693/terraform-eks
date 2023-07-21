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

variable "aws_eks_cluster_name" {
  type = string
  default = ""
}

variable "cluster_name" {
  default = ""
  type    = string
}