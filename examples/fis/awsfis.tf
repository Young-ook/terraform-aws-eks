module "aws" {
  source = "Young-ook/spinnaker/aws//modules/aws-partitions"
}

locals {
  aws = {
    dns       = module.aws.partition.dns_suffix
    partition = module.aws.partition.partition
    region    = module.aws.region.name
  }
}

resource "aws_iam_role" "fis-run" {
  name = local.fis_role_name
  tags = merge(local.default-tags, var.tags)
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = [format("fis.%s", local.aws.dns)]
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "fis-run" {
  policy_arn = format("arn:%s:iam::aws:policy/PowerUserAccess", local.aws.partition)
  role       = aws_iam_role.fis-run.id
}

### systems manager document for fault injection simulator experiment

resource "aws_ssm_document" "disk-stress" {
  name            = "FIS-Run-Disk-Stress"
  tags            = merge(local.default-tags, var.tags)
  document_format = "YAML"
  document_type   = "Command"
  content         = file("${path.cwd}/templates/disk-stress.yaml")
}

### fault injection simulator experiment templates

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

  experiments = [
    {
      in  = "cpu-stress.tpl"
      out = "cpu-stress.json"
      params = {
        region = var.aws_region
        alarm  = aws_cloudwatch_metric_alarm.cpu.arn
        role   = aws_iam_role.fis-run.arn
      }
    },
    {
      in  = "network-latency.tpl"
      out = "network-latency.json"
      params = {
        region = var.aws_region
        alarm  = local.stop_condition_alarm
        role   = aws_iam_role.fis-run.arn
      }
    },
    {
      in  = "throttle-ec2-api.tpl"
      out = "throttle-ec2-api.json"
      params = {
        asg_role = local.target_role
        alarm    = local.stop_condition_alarm
        role     = aws_iam_role.fis-run.arn
      }
    },
    {
      in  = "terminate-eks-nodes.tpl"
      out = "terminate-eks-nodes.json"
      params = {
        az        = var.azs[random_integer.az.result]
        vpc       = local.target_vpc
        nodegroup = local.target_eks_nodes
        role      = aws_iam_role.fis-run.arn
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
      in  = "disk-stress.tpl"
      out = "disk-stress.json"
      params = {
        doc_arn = aws_ssm_document.disk-stress.arn
        alarm   = aws_cloudwatch_metric_alarm.disk.arn
        role    = aws_iam_role.fis-run.arn
      }
    },
    {
      in  = "awsfis-init.tpl"
      out = "awsfis-init.sh"
      params = {
        region = var.aws_region
      }
    },
    {
      in  = "awsfis-cleanup.tpl"
      out = "awsfis-cleanup.sh"
      params = {
        region = var.aws_region
      }
    },
  ]
}

resource "local_file" "exp" {
  for_each        = { for k, v in local.experiments : k => v }
  content         = templatefile(join("/", [path.cwd, "templates", each.value.in]), each.value.params)
  filename        = join("/", [path.cwd, each.value.out])
  file_permission = "0600"
}

resource "null_resource" "awsfis-init" {
  depends_on = [local_file.exp]
  provisioner "local-exec" {
    when    = create
    command = "cd ${path.cwd}/.awsfis \n bash awsfis-init.sh"
  }
}

resource "null_resource" "awsfis-cleanup" {
  depends_on = [local_file.exp]
  provisioner "local-exec" {
    when    = destroy
    command = "cd ${path.cwd}/.awsfis \n bash awsfis-cleanup.sh \n rm -r ${path.cwd}/.awsfis"
  }
}
