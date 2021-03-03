

resource "kubernetes_namespace" "cluster_autoscaler" {
  count = var.enableautoscaler ? 1 : 0
  metadata { name = "cluster-autoscaler" }
}
resource "helm_release" "cluster_autoscaler" {
  count      = var.enableautoscaler ? 1 : 0
  depends_on = [kubernetes_namespace.cluster_autoscaler]
  name       = "cluster-autoscaler"
  namespace  = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler-chart"
  version    = "1.1.1"
  timeout    = "300"
  values = [
    <<-EOF
image:
  repository: us.gcr.io/k8s-artifacts-prod/autoscaling/cluster-autoscaler
  tag: v1.18.3
  #! This image tag should consolidate to current minor Kubernetes cluster version: 
  #! eg: if EKS Kubernetes cluster version = 1.15, than tag should be v1.15.<latest_patch>
  #! Find latest patch here: https://console.cloud.google.com/gcr/images/k8s-artifacts-prod/US/autoscaling/cluster-autoscaler
  # NOTE: This exact line is here to inform you need to change the image tag: ${data.aws_eks_cluster.cluster0.version}

cloudProvider: aws
awsRegion: ${var.aws_region}

autoDiscovery:
  clusterName: ${var.eks_cluster_name}

rbac:
  create: true

extraArgs:
  v: 4
  stderrthreshold: error
  logtostderr: true
  scan-interval: 60s
  balance-similar-node-groups: true
  skip-nodes-with-system-pods: false

EOF
  ]
}
