resource "null_resource" "update_kubeconfig" {

  provisioner "local-exec" {
    working_dir = path.module

    command = <<EOT
      aws eks --region ${var.aws_region} update-kubeconfig --name ${var.project_name} --kubeconfig ./${var.eks_cluster_name}.yml && sleep 30
    EOT

    interpreter = ["/bin/bash", "-c"]
  }
}
