### output variables

output "spinnaker" {
  description = "Spinnaker attributes"
  value = try(var.features.spinnaker_enabled, false) ? {
    irsa = module.devops.addons.irsa["spinnaker"]
  } : null
}
