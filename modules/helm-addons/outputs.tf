### output variables

output "addons" {
  description = "The attributes of helm addons"
  sensitive   = true
  value = {
    chart = helm_release.chart
    irsa  = module.irsa
  }
}
