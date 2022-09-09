data "aws_eks_cluster" "cluster_data" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "cluster_auth" {
  name = "${data.aws_eks_cluster.cluster_data.name}"
}
