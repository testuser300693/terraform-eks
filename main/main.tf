module "create_vpc" {
    source = "../modules/network"
    private_subnets = var.private_subnets
    public_subnets = var.public_subnets
    avail_zones = var.avail_zones
    vpc_block = var.vpc_block
}

module "create_cluster" {
    source = "../modules/cluster"
    private_subnet_ids = module.create_vpc.private_subnet_ids
    public_subnet_ids =  module.create_vpc.public_subnet_ids
    cluster_name = var.cluster_name
    # depends_on = [
    #     module.create_vpc
    # ]

}

module "create_worker" {
    source = "../modules/worker"
    depends_on = [module.create_cluster]
    aws_eks_cluster_name = module.create_cluster.aws_eks_cluster_name
    private_subnet_ids = module.create_vpc.private_subnet_ids
    public_subnet_ids =  module.create_vpc.public_subnet_ids

}

# module "create_autoscale" {
#     source = "../modules/autoscaler"
#     depends_on = [module.create_worker]
#     aws_eks_cluster_name = module.create_cluster.aws_eks_cluster_name

# }

module "ebs_addon" {
    source = "../modules/ebs-csi"
    depends_on = [module.create_worker]
    aws_eks_cluster_name = module.create_cluster.aws_eks_cluster_name

}

# module "k8s_apply_yaml" {
#     source = "../modules/kubernetes"
#     depends_on = [module.create_cluster]
#     aws_eks_cluster_name = module.create_cluster.aws_eks_cluster_name
#     aws_eks_cluster_endpoint = module.create_cluster.aws_eks_cluster_endpoint

# }