locals {
    cluster-name = "ironwolf-us-west-2"
    aws-profile  = null
    aws-region   = "us-west-2"
}

data "aws_eks_cluster" "cluster_data" {
  name = local.cluster-name
}

data "aws_eks_cluster_auth" "cluster_auth" {
  name = "${data.aws_eks_cluster.cluster_data.name}"
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_iam_openid_connect_provider" "cluster_oidc" {
  url = data.aws_eks_cluster.cluster_data.identity[0].oidc[0].issuer
}

data "aws_caller_identity" "user" {
}

data "aws_ses_domain_identity" "ses_domain" {
  domain = "rocroofingfl.com"
}

module "rocroofing" {
  source       = "../../modules/rocroofing"
  cluster-name = local.cluster-name
  service-name = "rocroofing"
  ses-domain   = "rocroofingfl.com"
  environment  = "prod"
}
