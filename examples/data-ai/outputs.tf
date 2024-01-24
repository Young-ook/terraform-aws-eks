output "kubeconfig" {
  description = "Bash script to update the kubeconfig file for the EKS cluster"
  value       = module.eks.kubeconfig
}

resource "local_file" "mnt-s3" {
  content = templatefile("${path.module}/apps/mnt-s3/templates/static-provisioning.tpl", {
    aws_region = local.aws.region
    s3_bucket  = module.s3.bucket.id
  })
  filename        = "${path.module}/apps/mnt-s3/static-provisioning.yaml"
  file_permission = "0700"
}
