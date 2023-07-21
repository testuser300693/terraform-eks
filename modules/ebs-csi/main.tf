data "aws_eks_cluster" "example" {
  name = var.aws_eks_cluster_name[0]
  # name = "demo"
}

data "tls_certificate" "eks" {
  url = data.aws_eks_cluster.example.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = data.aws_eks_cluster.example.identity[0].oidc[0].issuer
}

resource "aws_iam_role" "ebs_csi" {
  name = "terraform-eks-ebs-csi-role"

  # Terraform's "jsonencode" function converts a Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Condition = {
          StringEquals = {
            "${aws_iam_openid_connect_provider.eks.url}:aud": "sts.amazonaws.com" ,
            "${aws_iam_openid_connect_provider.eks.url}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }        

      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "amazon_eks_ebs_csi_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi.name
}

resource "aws_eks_addon" "ebs_eks_addon" {
  depends_on = [ aws_iam_role_policy_attachment.amazon_eks_ebs_csi_policy]
  cluster_name = var.aws_eks_cluster_name[0]
  addon_name   = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi.arn 
}

# resource "kubernetes_storage_class_v1" "ebs_sc" {  
#   metadata {
#     name = "ebs-gp2-sc"
#     annotations = {
#       "storageclass.kubernetes.io/is-default-class" = "true"
#     }
#   }
#   storage_provisioner = "ebs.csi.aws.com" #kubernetes.io/aws-ebs
#   volume_binding_mode = "WaitForFirstConsumer"
#   parameters = {
#     #"encrypted" = "true"
#     "fsType" = "ext4"
#     "type" = "gp2"
#   }
# }