# AWS EKS IAM ROLE
resource "aws_iam_role" "eksServiceRole" {
  name = "${var.project_name}-eksServiceRole"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY


  tags = {
    tag-key = "${var.project_name}-eks-cluster"
  }
  description = "Allows EKS to manage clusters on your behalf."
}


resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eksServiceRole.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eksServiceRole.name
}

# AWS EKS IAM ROLE

# AWS WORKERS IAM 

resource "aws_iam_role" "workers" {
  name = "${var.project_name}-eks-workers"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

}


resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.workers.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.workers.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.workers.name
}

resource "aws_iam_instance_profile" "eks_workers" {
  name = "${var.eks_cluster_name}-main-workers"
  role = aws_iam_role.workers.name
}

resource "aws_iam_role_policy_attachment" "workers_autoscaling" {
  policy_arn = aws_iam_policy.worker_autoscaling.arn
  role       = aws_iam_role.workers.name
}

resource "aws_iam_policy" "worker_autoscaling" {
  name        = "eks-worker-autoscaling"
  description = "EKS worker node autoscaling policy for cluster ${var.project_name}"
  policy      = <<AUTOSCALERPOLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeTags",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "ec2:DescribeLaunchTemplateVersions"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
AUTOSCALERPOLICY
}

# This policy allows access to predefined role in root account ↓↓↓↓↓↓↓↓↓
resource "aws_iam_policy" "access_to_root_dns" {
  name        = "AccessToRootDnsManagerRole"
  description = "Allows to access root Route53 zones from sub organization cluster"
  policy      = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
      {
        "Effect": "Allow",
        "Resource": "arn:aws:iam::310413357125:role/DnsManagerRole",
        "Action": "sts:AssumeRole"
      }
   ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "access_to_root_dns" {
  policy_arn = aws_iam_policy.access_to_root_dns.arn
  role       = aws_iam_role.workers.name
}

# AWS WORKERS IAM 










