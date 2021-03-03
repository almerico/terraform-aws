data "aws_availability_zones" "working" {}
data "aws_region" "current" {}
data "aws_eks_cluster" "cluster0" {
  name = local.cluster_name
}
data "aws_eks_cluster_auth" "cluster0" {
  name = local.cluster_name
}

data "aws_vpc" "main" {
  id = aws_vpc.eks_vpc.id
}

output "data_aws_region_name" {
  value = data.aws_region.current.name
}

output "data_aws_region_description" {
  value = data.aws_region.current.description
}
data "aws_vpc" "eks_vpc" {
  id = aws_vpc.eks_vpc.id
}

output "eks_workers_ami" {
  value = data.aws_ami.eks_workers_ami.name
}

output "eks_vpc_id" {
  value = data.aws_vpc.eks_vpc.id
}

output "cidr_block" {
  value = aws_vpc.eks_vpc.cidr_block
}

output "aws_availability_zones" {
  value = data.aws_availability_zones.working.names
}

output "endpoint" {
  value = data.aws_eks_cluster.cluster0.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = data.aws_eks_cluster.cluster0.certificate_authority[0].data
}

# Only available on Kubernetes version 1.13 and 1.14 clusters created or upgraded on or after September 3, 2019.
output "identity-oidc-issuer" {
  value = data.aws_eks_cluster.cluster0.identity[0].oidc[0].issuer
}
