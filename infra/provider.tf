terraform {
  required_version = ">= 0.14.0"
#    backend "s3" {
#     bucket = "itterate-terraform-state"
#     key    = "terraform/prod/state"
#     region = "us-east-1"
#  }
}

provider "aws" {
  profile = "iterate"
  region = "us-east-1"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster0.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster0.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster0.token
}
// Helm provider (depends on AWS provider data)
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster0.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster0.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster0.token
  }
}
// # WARNING: Kubernetes Alpha Experimental provider to handle custom resources and manifests
provider "kubernetes-alpha" {
  # load_config_file       = false
  host                   = data.aws_eks_cluster.cluster0.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster0.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster0.token
}
