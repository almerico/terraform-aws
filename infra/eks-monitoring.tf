###* Monitoring and Logging *###

output "prometheus_stack_grafana_password" {
  value = random_password.prometheus_stack_grafana_password.result
}

resource "random_password" "prometheus_stack_grafana_password" {
  length  = 32
  special = false
}

resource "helm_release" "prometheus_stack" {
  count         = var.eks_0_monitoring_config.enable ? 1 : 0
  depends_on    = [kubernetes_namespace.monitoring, random_password.prometheus_stack_grafana_password]
  namespace     = "monitoring"
  version       = "12.2.0"
  name          = "kube-prometheus-stack"
  chart         = "kube-prometheus-stack"
  repository    = "https://prometheus-community.github.io/helm-charts"
  timeout       = "300"
  recreate_pods = "true"
  values = [
    <<-EOF
alertmanager:
  config:
    global:
      resolve_timeout: 5m
      slack_api_url: '${var.eks_0_monitoring_config.slack_webhook}'
    route:
      group_by: ['alertname', 'cluster', 'service']
      group_wait: 30s
      group_interval: 5m
      repeat_interval: 1m
      receiver: default-receiver
      routes:
      - match:
          alertname: Watchdog # Default alerting health-check
        receiver: 'null'
      - match:
          alertname: KubeClientCertificateExpiration # AWS
        receiver: 'null'
      - match:
          alertname: KubeVersionMismatch # AWS
        receiver: 'null'
      - match:
          alertname: CPUThrottlingHigh # AWS, GKE
        receiver: 'null'
      # - match:
      #     alertname: ClockSkewDetected # GKE
      #   receiver: 'null'
      # - match:
      #     alertname: KubeMemOvercommit # DO  https://github.com/kubernetes-monitoring/kubernetes-mixin/issues/162
      #   receiver: 'null'
      # - match:
      #     alertname: KubeCPUOvercommit # DO  https://github.com/kubernetes-monitoring/kubernetes-mixin/issues/97
      #   receiver: 'null'
    inhibit_rules:
    - source_match:
        severity: 'critical'
      target_match:
        severity: 'warning'
      # Apply inhibition if the alertname is the same.
      equal: ['alertname', 'cluster', 'service']
    receivers:
    - name: 'default-receiver'
      slack_configs:
      - channel: '${var.eks_0_monitoring_config.slack_channel}'
        username: '{{ template "slack.default.username" . }}'
        color: '{{ if eq .Status "firing" }}danger{{ else }}good{{ end }}'
        title: '[{{ .Status | toUpper }}{{ if eq .Status "firing" }}:{{ .Alerts.Firing | len }}{{ end }}] Prometheus Event Notification'
        title_link: '{{ template "slack.default.titlelink" . }}'
        pretext: '{{ .CommonAnnotations.summary }}'
        text: |-
          {{ range .Alerts }}
            {{- if .Annotations.summary }}*Alert:* {{ .Annotations.summary }} - `{{ .Labels.severity }}`{{- end }}
            *Description:* {{ .Annotations.description }}{{ .Annotations.message }}
            *Graph:* <{{ .GeneratorURL }}|:chart_with_upwards_trend:>{{ if or .Annotations.runbook .Annotations.runbook_url }} *Runbook:* <{{ .Annotations.runbook }}{{ .Annotations.runbook_url }}|:spiral_note_pad:>{{ end }}
            *Details:*
            {{ range .Labels.SortedPairs }} • *{{ .Name }}:* `{{ .Value }}`
            {{ end }}
          {{ end }}
        fallback: '{{ template "slack.default.fallback" . }}'
        icon_emoji: '{{ template "slack.default.iconemoji" . }}'
        icon_url: '{{ template "slack.default.iconurl" . }}'
        send_resolved: true
    - name: 'null'
  alertmanagerSpec:
    storage:
      volumeClaimTemplate:
        spec:
          storageClassName: gp2 # AWS
          # storageClassName: do-block-storage # DO
          # storageClassName: standard # GKE
          accessModes: ["ReadWriteOnce"] # AWS, DO
          # accessModes: ["ReadOnlyMany"] # GKE
          resources:
            requests:
              storage: 5Gi
    nodeSelector:
      workload-type: monitoring
grafana:
  adminPassword: '${random_password.prometheus_stack_grafana_password.result}'
  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: nginx
      cert-manager.io/cluster-issuer: letsencrypt-http
    hosts:
      - ${var.eks_0_monitoring_config.grafana_hostname}
    path: /
    tls:
    - secretName: ${var.eks_0_monitoring_config.grafana_hostname}-tls
      hosts:
      - ${var.eks_0_monitoring_config.grafana_hostname}
  persistence:
    enabled: true
    storageClassName: gp2 # AWS
    # storageClassName: do-block-storage # DO
    # storageClassName: standard # GKE
    accessModes:
      - ReadWriteOnce # AWS, DO
      # - ReadOnlyMany # GKE
    size: 5Gi
    annotations: {}
  additionalDataSources:
  - name: Loki
    access: proxy
    editable: true
    type: loki
    url: http://loki-stack:3100
    version: 1
kubelet:
  serviceMonitor:
   # https: false # GKE
   https: true # AWS, Default
kubeControllerManager:
  # enabled: true # GKE, Default
  enabled: false # AWS, DO
coreDns:
  enabled: true
  service:
    port: 9153        # AWS, DO, Default
    targetPort: 9153  # AWS, DO, Default
    # port: 10054       # GKE
    # targetPort: 10054 # GKE
    selector:
      # k8s-app: kube-dns # GKE, DO, Default
      k8s-app: coredns # AWS
kubeEtcd:
  enabled: true # GKE, Default
  # enabled: false # AWS, DO
kubeScheduler:
  # enabled: true # GKE, Default
  enabled: false # AWS, DO
kubeProxy:
  # enabled: true # Default
  enabled: false # DO, AWS, GKE (kube-proxy in EKS/DO listen only localhost because of security)
prometheus-node-exporter:
  service:
    # port: 30206       # DO
    # targetPort: 30206 # DO
    port: 9100       # Default, AWS, GKE
    targetPort: 9100 # Default, AWS, GKE
prometheusOperator:
  createCustomResource: true # NOTE: You may need to disable this on a second helm run, as CRDs will be already in place
  tlsProxy:
    enabled: true # AWS, Default
    # enabled: false # GKE
  admissionWebhooks:
    failurePolicy: Fail
    enabled: true # AWS, DO, Default
    # enabled: false # GKE
  nodeSelector:
    workload-type: monitoring
prometheus:
  prometheusSpec:
    nodeSelector:
      workload-type: monitoring
    storageSpec:
      volumeClaimTemplate:
        spec:
          storageClassName: gp2 # AWS
          # storageClassName: do-block-storage # DO
          # storageClassName: standard # GKE
          accessModes: ["ReadWriteOnce"] # AWS, Default
          # accessModes: ["ReadOnlyMany"] # GKE
          resources:
            requests:
              storage: 35Gi

EOF
  ]
}

output "prometheus_stack" {
  value = var.eks_0_monitoring_config.enable == true ? "URL = https://${var.eks_0_monitoring_config.grafana_hostname}, LOGIN = admin, PASSWORD = ${random_password.prometheus_stack_grafana_password.result}" : "Monitoring Stack Disabled"
}

resource "helm_release" "loki_stack" {
  count      = var.eks_0_monitoring_config.enable ? 1 : 0
  depends_on = [kubernetes_namespace.monitoring]
  version    = "2.0.3"
  namespace  = "monitoring"
  name       = "loki-stack"
  chart      = "loki-stack"
  repository = "https://grafana.github.io/loki/charts"
  timeout    = "300"
  values = [
    <<-EOF
loki:
  persistence:
    enabled: true
    accessModes:
    - ReadWriteOnce
    size: 15Gi
    storageClassName: gp2
    annotations: {}
  nodeSelector:
    workload-type: monitoring
  EOF
  ]
}
