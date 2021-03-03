resource "kubernetes_namespace" "ingress_nginx" {
  metadata { name = "ingress-nginx" }
}
resource "helm_release" "ingress_nginx" {
  count      = var.enablenginx ? 1 : 0
  depends_on = [kubernetes_namespace.ingress_nginx]
  name       = "ingress-nginx"
  namespace  = "ingress-nginx"
  wait       = true

  chart      = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  version    = "3.9.0"
  timeout    = "300"
  # NOTE: `controller.config` ref: https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/#configuration-options
  values = [
    <<-EOF
controller:
  config:
    use-gzip: "true"
    gzip-level: "1"
    # log-format-escape-json: "true"
    # log-format-upstream: '{"timestamp":"$time_iso8601", "requestID":"$req_id", "proxyUpstreamName":"$proxy_upstream_name",
    #   "proxyAlternativeUpstreamName":"$proxy_alternative_upstream_name", "upstreamStatus":"$upstream_status", "upstreamAddr":"$upstream_addr",
    #   "httpRequest":{"requestMethod":"$request_method", "requestUrl":"$host$request_uri", "status":"$status",
    #   "requestSize":"$request_length", "responseSize":"$upstream_response_length", "userAgent":"$http_user_agent",
    #   "remoteIp":"$remote_addr", "referer":"$http_referer", "latency":"$upstream_response_time", "protocol":"$server_protocol"}}'
  ingressClass: nginx
  replicaCount: 2
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 4
    targetCPUUtilizationPercentage: 100
    targetMemoryUtilizationPercentage: 100
  # affinity:
  #   podAntiAffinity:
  #     preferredDuringSchedulingIgnoredDuringExecution:
  #     - weight: 100
  #       podAffinityTerm:
  #         labelSelector:
  #           matchExpressions:
  #           - key: release
  #             operator: In
  #             values:
  #             - ingress-nginx
  #         topologyKey: kubernetes.io/hostname
  #   nodeAffinity:
  #     requiredDuringSchedulingIgnoredDuringExecution:
  #       nodeSelectorTerms:
  #       - matchExpressions:
  #         - key: "workload-type"
  #           operator: In
  #           values: [${var.main_worker_group_name}]

  resources:
    requests:
      cpu: 200m
      memory: 250Mi
    limits:
      cpu: 750m
  # metrics:
  #   enabled: true
  #   serviceMonitor:
  #     enabled: true
  #     additionalLabels:
  #       release: "prometheus-operator"

# defaultBackend:
#   affinity:
#     nodeAffinity:
#       preferredDuringSchedulingIgnoredDuringExecution:
#       - weight: 50
#         preference:
#           matchExpressions:
#           - key: "workloadtype"
#             operator: In
#             values: [${var.main_worker_group_name}]

  resources:
    requests:
      cpu: 10m
      memory: 20Mi
    limits:
      cpu: 100m
      memory: 125Mi
EOF
  ]
}

# Load Balancer output
data "kubernetes_service" "ingress_nginx" {
  depends_on = [helm_release.ingress_nginx] # Always triggers data refresh
  metadata {
    name      = "ingress-nginx-controller"
    namespace = helm_release.ingress_nginx[0].namespace
  }
}

//output ingress_nginx_loadbalancer_ip {
//  value = data.kubernetes_service.ingress_nginx.load_balancer_ingress.0.ip
//}
