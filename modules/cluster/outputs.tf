output "aws_eks_cluster_name" {
    value = aws_eks_cluster.demo[*].name
}

output "aws_eks_cluster_endpoint" {
    value = aws_eks_cluster.demo[*].endpoint
}

# output "aws_load_balancer_controller_role_arn" {
#   value = aws_iam_role.aws_load_balancer_controller.arn
# }