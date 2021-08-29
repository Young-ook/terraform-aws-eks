### application/monitoring
resource "aws_cloudwatch_metric_alarm" "cpu" {
  alarm_name                = local.cw_cpu_alarm_name
  alarm_description         = "This metric monitors ec2 cpu utilization"
  tags                      = merge(local.default-tags, var.tags)
  metric_name               = "node_cpu_utilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = 1
  evaluation_periods        = 1
  namespace                 = "ContainerInsights"
  period                    = 30
  threshold                 = 60
  statistic                 = "Average"
  insufficient_data_actions = []

  dimensions = {
    ClusterName = module.eks.cluster.name
  }
}

resource "aws_cloudwatch_metric_alarm" "disk" {
  alarm_name                = local.cw_disk_alarm_name
  alarm_description         = "This metric monitors ec2 disk filesystem usage"
  tags                      = merge(local.default-tags, var.tags)
  metric_name               = "node_filesystem_utilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = 1
  evaluation_periods        = 1
  namespace                 = "ContainerInsights"
  period                    = 30
  threshold                 = 60
  extended_statistic        = "p90"
  insufficient_data_actions = []

  dimensions = {
    ClusterName = module.eks.cluster.name
  }
}
