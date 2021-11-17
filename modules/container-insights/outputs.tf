# output variables

output "helm" {
  description = "The generated attributes of helm packages"
  value = zipmap(
    ["metrics", "logs"],
    [helm_release.metrics, helm_release.logs]
  )
}

output "features" {
  description = "Features configurations for cloudwatch container insights"
  value = {
    "metrics_enabled" = local.metrics_enabled
    "logs_enabled"    = local.logs_enabled
  }
}
