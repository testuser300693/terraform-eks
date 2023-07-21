data "aws_eks_cluster_auth" "cluster_auth" {
  name = var.aws_eks_cluster_name[0]
}

data "aws_eks_cluster" "example" {
  name = var.aws_eks_cluster_name[0]
}

data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

provider "kubernetes" {
  host                   = var.aws_eks_cluster_endpoint[0]
  cluster_ca_certificate = "${base64decode(data.aws_eks_cluster.example.certificate_authority[0].data)}"
  token                  = "${data.aws_eks_cluster_auth.cluster_auth.token}"
  # load_config_file       = false
}

resource "kubernetes_config_map" "aws_auth_configmap" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
  data = {
      mapRoles = <<YAML
  - rolearn: arn:aws:iam::194968952280:role/AmazonEKSNodeRole
    username: system:node:{{EC2PrivateDNSName}}
    groups:
      - system:bootstrappers
      - system:nodes
  - rolearn: arn:aws:iam::194968952280:root
    username: kubectl-access-user
    groups:
      - system:masters
  YAML
    }
}

# resource "kubernetes_config_map" "aws_auth_configmap" {
#   metadata {
#     name      = "aws-auth"
#     namespace = "kube-system"
#   }
#   data = {
#         mapRoles = <<YAML
#     - rolearn: arn:aws:iam::194968952280:role/AmazonEKSNodeRole
#       username: system:node:{{EC2PrivateDNSName}}
#       groups:
#         - system:bootstrappers
#         - system:nodes
#     - rolearn: arn:aws:iam::194968952280:root
#       username: kubectl-access-user
#       groups:
#         - system:masters
#     YAML
#   }
# }