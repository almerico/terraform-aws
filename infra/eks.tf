resource "aws_eks_cluster" "eks_cluster" {

  count    = var.create_eks ? 1 : 0
  name     = local.cluster_name
  role_arn = aws_iam_role.eksServiceRole.arn

  vpc_config {
    subnet_ids = aws_subnet.eks_subnet.*.id
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy,
  ]
}

