### output variables

output "spinnaker" {
  description = "Spinnaker attributes"
  value = try(var.features.spinnaker_enabled, false) ? {
    irsa = module.devops.addons.irsa["spinnaker"]
  } : null
}

resource "local_file" "halconfig" {
  for_each = (try(var.features.spinnaker_enabled, false) ? toset(["enabled"]) : [])
  content = templatefile("${path.module}/scripts/templates/halconfig.tpl", {
    aws_id            = local.aws.id
    aws_region        = local.aws.region
    spin_managed_role = module.devops.addons.irsa["spinnaker"].arn
    spin_irsa_cli     = module.devops.addons.irsa["spinnaker"].kubecli
  })
  filename        = "${path.module}/scripts/halconfig.sh"
  file_permission = "0700"
}
