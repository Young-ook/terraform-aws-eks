output "kubeconfig" {
  description = "Bash script to update the kubeconfig file for the EKS cluster"
  value       = module.eks.kubeconfig
}

output "codebuild" {
  description = "Bash script to run the build projects using CodeBuild"
  value       = [for proj in values(module.ci) : proj.build]
}

output "features" {
  description = "Features configurations of the AWS EKS cluster"
  value       = module.eks.features
}

### aws partitions
module "aws" {
  source = "Young-ook/spinnaker/aws//modules/aws-partitions"
}

locals {
  aws = {
    id     = module.aws.caller.account_id
    region = module.aws.region.name
  }
}

resource "local_file" "halconfig" {
  for_each = (local.spinnaker_enabled ? toset(["enabled"]) : [])
  content = templatefile("${path.module}/scripts/templates/halconfig.tpl", {
    aws_id            = local.aws.region
    aws_region        = local.aws.id
    spin_managed_role = module.kubernetes-addons.spinnaker.irsa.arn
    spin_irsa_cli     = module.kubernetes-addons.spinnaker.irsa.kubecli
  })
  filename        = "${path.cwd}/scripts/halconfig.sh"
  file_permission = "0700"
}
