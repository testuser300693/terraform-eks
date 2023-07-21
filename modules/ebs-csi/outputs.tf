output "ebs_csi_iam_role_arn" {
  description = "EBS CSI IAM Role ARN"
  value = data.aws_eks_cluster.example.identity[0].oidc[0].issuer
}