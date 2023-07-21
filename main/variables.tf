variable "region" {
    type = string
    description = "aws region to deploy cluster in"
    default = "ap-south-1"
  
}

# variable "subnets" {
#   type = map
#   default = {
#     "private_subnets"  = ["10.0.0.0/19", "10.0.32.0/19"]
#     "public_subnets" = ["10.0.64.0/19", "10.0.96.0/19"]
#   }
# }

variable "avail_zones" {
  type = list
  default = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}

variable "vpc_block" {
  type = string
  default = ""
}

variable "private_subnets" {
  description = ""
  type        = list(string)
  default     = []
}

variable "public_subnets" {
  description = ""
  type        = list(string)
  default     = []
}

variable "aws_eks_cluster_name" {
  type = string
  default = ""
}

variable "cluster_name" {
  default = "example"
  type    = string
}