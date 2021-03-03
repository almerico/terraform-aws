variable "env_name" {
  default = "staging"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_cidr_block" {
  default = "10.15.0.0/19"
}

variable "public_subnets" {
  type    = list(any)
  default = ["10.15.0.0/22", "10.15.4.0/22", "10.15.8.0/22"]
}

variable "project_name" {
  default = "iterate"
}

variable "instance_type" {
  default = "t3.medium"
}

variable "ssh_key" {
  default = "web"
}

variable "eks_cluster_name" {
  default = "iterate-cluster"
}

variable "worker_monitoring_disk_size" {
  default = 50
}

variable "worker_main_disk_size" {
  default = 50
}

variable "worker_staging_disk_size" {
  default = 50
}


#scaling main
variable "worker_main_scaling_config_desired_size" {
  default = 2
}

variable "worker_main_scaling_config_max_size" {
  default = 4
}

variable "worker_main_scaling_config_min_size" {
  default = 1
}


#scaling staging
variable "worker_staging_scaling_config_desired_size" {
  default = 2
}

variable "worker_staging_scaling_config_max_size" {
  default = 4
}

variable "worker_staging_scaling_config_min_size" {
  default = 1
}

#scaling monitoring
variable "worker_monitoring_scaling_config_desired_size" {
  default = 1
}

variable "worker_monitoring_scaling_config_max_size" {
  default = 3
}

variable "worker_monitoring_scaling_config_min_size" {
  default = 1
}

variable "domain_default" {
  default = "iterate.co"
}

variable "main_worker_group_name" {
  default = "production"
}


variable "monitoring_worker_group_name" {
  default = "monitoring"
}

variable "staging_worker_group_name" {
  default = "staging"
}

variable "eks_0_monitoring_config" {
  default = {
    enable           = false # Deploy prometheus-operator and loki-stack
    slack_webhook    = "https://hooks.slack.com/services/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"
    slack_channel    = "maintenance_debug"
    grafana_hostname = "grafana.proteyah.com"
  }
  description = "Kube Prometheus-stack and Loki-stack config"
}

variable "create_elasticache" {
  default = true
}

variable "create_rds" {
  default = true
}

variable "postgres_username" {
  default = "api_u"
}

variable "postgres_password" {
  default = "uxarykxn"
}
variable "enableautoscaler" {
  default = false
}

variable "enablenginx" {
  default = false
}
variable "create_eks" {
  default = true
}


variable "s3_name" {
  default = "buket"
}
