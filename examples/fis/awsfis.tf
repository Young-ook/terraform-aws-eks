
### systems manager document for fault injection simulator experiment

resource "aws_ssm_document" "disk-stress" {
  name            = "FIS-Run-Disk-Stress"
  tags            = merge(local.default-tags, var.tags)
  document_format = "YAML"
  document_type   = "Command"
  content         = file("${path.cwd}/templates/disk-stress.yaml")
}

resource "random_integer" "az" {
  min = 0
  max = length(var.azs) - 1
}

locals {
  target_vpc           = module.vpc.vpc.id
  target_role          = module.eks.role.arn
  target_asg           = module.eks.cluster.data_plane.managed_node_groups.sockshop.resources.0.autoscaling_groups.0.name
  target_eks_nodes     = module.eks.cluster.data_plane.managed_node_groups.sockshop.arn
  stop_condition_alarm = aws_cloudwatch_metric_alarm.cpu.arn
  fis_role             = module.awsfis.role.arn

  experiments = [
    {
      name     = "cpu-stress"
      template = "${path.cwd}/templates/cpu-stress.tpl"
      params = {
        region = var.aws_region
        alarm  = aws_cloudwatch_metric_alarm.cpu.arn
        role   = local.fis_role
      }
    },
    {
      name     = "network-latency"
      template = "${path.cwd}/templates/network-latency.tpl"
      params = {
        region = var.aws_region
        alarm  = local.stop_condition_alarm
        role   = local.fis_role
      }
    },
    {
      name     = "throttle-ec2-api"
      template = "${path.cwd}/templates/throttle-ec2-api.tpl"
      params = {
        asg_role = local.target_role
        alarm    = local.stop_condition_alarm
        role     = local.fis_role
      }
    },
    {
      name     = "terminate-eks-nodes"
      template = "${path.cwd}/templates/terminate-eks-nodes.tpl"
      params = {
        az        = var.azs[random_integer.az.result]
        vpc       = local.target_vpc
        nodegroup = local.target_eks_nodes
        role      = local.fis_role
        alarm = jsonencode([
          {
            source = "aws:cloudwatch:alarm"
            value  = aws_cloudwatch_metric_alarm.cpu.arn
          },
          {
            source = "aws:cloudwatch:alarm"
            value  = aws_cloudwatch_metric_alarm.svc-health.arn
        }])
      }
    },
    {
      name     = "disk-stress"
      template = "${path.cwd}/templates/disk-stress.tpl"
      params = {
        doc_arn = aws_ssm_document.disk-stress.arn
        alarm   = aws_cloudwatch_metric_alarm.disk.arn
        role    = local.fis_role
      }
    },
  ]
}

module "awsfis" {
  source      = "Young-ook/fis/aws"
  name        = var.name
  tags        = var.tags
  experiments = local.experiments
}
