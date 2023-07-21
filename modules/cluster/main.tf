# resource "aws_iam_role" "demo" {
#   name = "eks-cluster-demo"

#   assume_role_policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "eks.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# POLICY
# }

resource "aws_iam_role" "demo" {
  name = "terraform-eks-cluster-role"

  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = [
              "eks-fargate-pods.amazonaws.com",
              "eks.amazonaws.com",
            ]
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  # force_detach_policies = false
  # max_session_duration  = 3600
  # name                  = "eks-cluster-ServiceRole-HUIGIC7K7HNJ"
  # path                  = "/"
  # tags = {
  #   "Name"                                        = "eks-cluster/ServiceRole"

  # }
}

resource "aws_iam_role_policy_attachment" "demo_amazon_eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.demo.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly-EKS" {
 policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
 role    = aws_iam_role.demo.name
}

resource "aws_eks_cluster" "demo" {
  name     = var.cluster_name
  version  = "1.27"
  role_arn = aws_iam_role.demo.arn

  vpc_config {
    subnet_ids = [
        var.private_subnet_ids[0],
        var.private_subnet_ids[1],
        var.public_subnet_ids[0],
        var.public_subnet_ids[1]
    ]
  }

  depends_on = [aws_iam_role_policy_attachment.demo_amazon_eks_cluster_policy]
}

# data "tls_certificate" "eks" {
#   url = aws_eks_cluster.demo.identity[0].oidc[0].issuer
# }

# resource "aws_iam_openid_connect_provider" "eks" {
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
#   url             = aws_eks_cluster.demo.identity[0].oidc[0].issuer
# }


# data "aws_iam_policy_document" "aws_load_balancer_controller_assume_role_policy" {
#   statement {
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     effect  = "Allow"

#     condition {
#       test     = "StringEquals"
#       variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
#       values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
#     }

#     principals {
#       identifiers = [aws_iam_openid_connect_provider.eks.arn]
#       type        = "Federated"
#     }
#   }
# }

# resource "aws_iam_role" "aws_load_balancer_controller" {
#   assume_role_policy = data.aws_iam_policy_document.aws_load_balancer_controller_assume_role_policy.json
#   name               = "aws-load-balancer-controller"
# }

# #modules\cluster\main.tf
# resource "aws_iam_policy" "aws_load_balancer_controller" {
#   policy = file("./modules/cluster/AWSLoadBalancerController.json")
#   name   = "AWSLoadBalancerController"
# }

# resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller_attach" {
#   role       = aws_iam_role.aws_load_balancer_controller.name
#   policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
# }

data "aws_eks_cluster_auth" "cluster_auth" {
  name = var.cluster_name
}

data "aws_caller_identity" "current" {}

provider "kubernetes" {
  # load_config_file       = false
  host                   = "${aws_eks_cluster.demo.endpoint}"
  cluster_ca_certificate = "${base64decode(aws_eks_cluster.demo.certificate_authority.0.data)}"
  token                  = "${data.aws_eks_cluster_auth.cluster_auth.token}"
  
}

# locals {
#   policy = templatefile("${path.module}/configmap_aws_auth.tpl", {
#     name = data.aws_caller_identity.current.account_id
#   })
# }

# resource "kubernetes_config_map" "aws_auth_configmap" {
#   metadata {
#     name      = "aws-auth"
#     namespace = "kube-system"
#   }
#   data = {
#     "configmap_aws_auth.yml" = "${file("${path.module}/configmap_aws_auth.yml")}"
#   }
# }

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