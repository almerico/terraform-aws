data "aws_ami" "eks_workers_ami" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.eks_cluster[0].version}-v*"]
  }
  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}


resource "aws_eks_node_group" "workers_main" {

  cluster_name    = aws_eks_cluster.eks_cluster[0].name
  node_group_name = "${var.project_name}-main-workers"
  node_role_arn   = aws_iam_role.workers.arn
  subnet_ids      = aws_subnet.eks_subnet[*].id
  disk_size       = var.worker_main_disk_size
  instance_types  = [var.instance_type]

  remote_access {
    ec2_ssh_key = var.ssh_key
  }

  scaling_config {
    desired_size = var.worker_main_scaling_config_desired_size
    max_size     = var.worker_main_scaling_config_max_size
    min_size     = var.worker_main_scaling_config_min_size
  }

  tags = {
    Name                                            = "${var.project_name}-main-workers-group"
    CreatedBy                                       = "terraform"
    "kubernetes.io/cluster/${var.project_name}"     = "owned",
    "k8s.io/cluster-autoscaler/${var.project_name}" = "true",
    "k8s.io/cluster-autoscaler/enabled"             = "true"
  }

  labels = {
    "eks-cluster/nodegroup" = var.main_worker_group_name,
    "nodegroup"             = var.main_worker_group_name
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.workers_autoscaling,
		aws_eks_cluster.eks_cluster
  ]
}

resource "aws_eks_node_group" "workers_monitoring" {
  count           = var.eks_0_monitoring_config.enable ? 1 : 0
  cluster_name    = aws_eks_cluster.eks_cluster[0].name
  node_group_name = "${var.project_name}-monitoring-workers"
  node_role_arn   = aws_iam_role.workers.arn
  subnet_ids      = aws_subnet.eks_subnet.*.id
  disk_size       = var.worker_monitoring_disk_size
  instance_types  = [var.instance_type]

  remote_access {
    ec2_ssh_key = var.ssh_key
  }

  scaling_config {
    desired_size = var.worker_monitoring_scaling_config_desired_size
    max_size     = var.worker_monitoring_scaling_config_max_size
    min_size     = var.worker_monitoring_scaling_config_min_size
  }

  tags = {
    Name                                            = "${var.project_name}-monitoring-workers-group"
    CreatedBy                                       = "terraform"
    "kubernetes.io/cluster/${var.project_name}"     = "owned",
    "k8s.io/cluster-autoscaler/${var.project_name}" = "true",
    "k8s.io/cluster-autoscaler/enabled"             = "true"
  }

  labels = {
    "eks-cluster/nodegroup" = var.monitoring_worker_group_name,
    "nodegroup"             = var.monitoring_worker_group_name,
    "workload-type"         = var.monitoring_worker_group_name
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.workers_autoscaling,
		aws_eks_cluster.eks_cluster
  ]
}

resource "aws_eks_node_group" "workers_staging" {
  cluster_name    = aws_eks_cluster.eks_cluster[0].name
  node_group_name = "${var.project_name}-staging-workers"
  node_role_arn   = aws_iam_role.workers.arn
  subnet_ids      = aws_subnet.eks_subnet.*.id
  disk_size       = var.worker_staging_disk_size
  instance_types  = [var.instance_type]

  remote_access {
    ec2_ssh_key = var.ssh_key
  }

  scaling_config {
    desired_size = var.worker_staging_scaling_config_desired_size
    max_size     = var.worker_staging_scaling_config_max_size
    min_size     = var.worker_staging_scaling_config_min_size
  }

  tags = {
    Name                                            = "${var.project_name}-staging-workers-group"
    CreatedBy                                       = "terraform"
    "kubernetes.io/cluster/${var.project_name}"     = "owned",
    "k8s.io/cluster-autoscaler/${var.project_name}" = "true",
    "k8s.io/cluster-autoscaler/enabled"             = "true"
  }

  labels = {
    "eks-cluster/nodegroup" = var.staging_worker_group_name
    "nodegroup"             = var.staging_worker_group_name
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.workers_autoscaling,
		aws_eks_cluster.eks_cluster
  ]
}
