variable "vpc_block" {
  type = string
  default = ""
}

variable "avail_zones" {
  type = list(string)
  default = []
}

variable "private_subnets" {
  description = ""
  type        = list(string)
  # default     = []
}

variable "public_subnets" {
  description = ""
  type        = list(string)
  # default     = []
}