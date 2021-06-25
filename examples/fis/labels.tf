locals {
  alb_name                        = join("-", [var.name, "alb"])
  alb_sg_name                     = join("-", [var.name, "alb"])
  alb_aware_sg_name               = join("-", [var.name, "alb-aware"])
  cw_cpu_alarm_name               = join("-", [var.name, "cpu-alarm"])
  cw_api_p90_alarm_name           = join("-", [var.name, "api-p90-alarm"])
  cw_api_avg_alarm_name           = join("-", [var.name, "api-avg-alarm"])
  asg_target_tracking_policy_name = join("-", [var.name, "target-tracking-autoscaling-policy"])
  fis_role_name                   = join("-", [var.name, "role"])
  default-tags = merge(
    { "terraform.io" = "managed" },
  )
}
