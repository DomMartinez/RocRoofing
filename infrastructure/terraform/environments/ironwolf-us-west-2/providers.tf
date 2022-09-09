provider "aws" {
  profile = local.aws-profile
  region  = local.aws-region
  version = "4.11.0"
}

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "kubernetes" {
  host                    = data.aws_eks_cluster.cluster_data.endpoint
  cluster_ca_certificate  = base64decode(data.aws_eks_cluster.cluster_data.certificate_authority.0.data)
  token                   = data.aws_eks_cluster_auth.cluster_auth.token
  load_config_file        = false
  version                 = "1.13.3"
}
