
locals {
  s3_bucket_name = "${var.env_name}-${var.s3_name}"
  cluster_name   = "${var.project_name}-cluster"
}
