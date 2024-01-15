### output variables

output "spinnaker" {
  description = "Spinnaker attributes"
  value = {
    irsa = module.devops.addons.irsa["spinnaker"]
  }
}
