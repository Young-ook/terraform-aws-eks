module "current" {
  source  = "Young-ook/spinnaker/aws//modules/aws-partitions"
  version = ">= 2.0"
}

resource "aws_iam_role" "fis-run" {
  name = local.fis_role_name
  tags = merge(local.default-tags, var.tags)
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = [format("fis.%s", module.current.partition.dns_suffix)]
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "fis-run" {
  policy_arn = format("arn:%s:iam::aws:policy/PowerUserAccess", module.current.partition.partition)
  role       = aws_iam_role.fis-run.id
}

### fault injection simulator experiment templates

locals {
  target_vpc           = module.vpc.vpc.id
  target_role          = module.eks.role.arn
  target_asg           = module.eks.cluster.data_plane.managed_node_groups.sockshop.resources.0.autoscaling_groups.0.name
  stop_condition_alarm = aws_cloudwatch_metric_alarm.cpu.arn
}

resource "local_file" "cpu-stress" {
  content = templatefile("${path.module}/templates/cpu-stress.tpl", {
    asg    = local.target_asg
    region = var.aws_region
    alarm  = local.stop_condition_alarm
    role   = aws_iam_role.fis-run.arn
  })
  filename        = "${path.cwd}/cpu-stress.json"
  file_permission = "0600"
}

resource "local_file" "network-latency" {
  content = templatefile("${path.module}/templates/network-latency.tpl", {
    asg    = local.target_asg
    region = var.aws_region
    alarm  = local.stop_condition_alarm
    role   = aws_iam_role.fis-run.arn
  })
  filename        = "${path.cwd}/network-latency.json"
  file_permission = "0600"
}

resource "random_integer" "az" {
  min = 0
  max = length(var.azs) - 1
}

resource "local_file" "terminate-instances" {
  content = templatefile("${path.module}/templates/terminate-instances.tpl", {
    asg   = local.target_asg
    az    = var.azs[random_integer.az.result]
    vpc   = local.target_vpc
    alarm = local.stop_condition_alarm
    role  = aws_iam_role.fis-run.arn
  })
  filename        = "${path.cwd}/terminate-instances.json"
  file_permission = "0600"
}

resource "local_file" "throttle-ec2-api" {
  content = templatefile("${path.module}/templates/throttle-ec2-api.tpl", {
    asg_role = local.target_role
    alarm    = local.stop_condition_alarm
    role     = aws_iam_role.fis-run.arn
  })
  filename        = "${path.cwd}/throttle-ec2-api.json"
  file_permission = "0600"
}

resource "local_file" "terminate-eks-nodes" {
  content = templatefile("${path.module}/templates/terminate-eks-nodes.tpl", {
    az    = var.azs[random_integer.az.result]
    vpc   = local.target_vpc
    alarm = local.stop_condition_alarm
    role  = aws_iam_role.fis-run.arn
  })
  filename        = "${path.cwd}/terminate-eks-nodes.json"
  file_permission = "0600"
}

resource "local_file" "create-templates" {
  content = join("\n", [
    "#!/bin/bash -ex",
    "OUTPUT='.fis_cli_result'",
    "TEMPLATES=('cpu-stress.json' 'network-latency.json' 'terminate-instances.json' 'throttle-ec2-api.json' 'terminate-eks-nodes.json')",
    "for template in $${TEMPLATES[@]}; do",
    "  aws fis create-experiment-template --cli-input-json file://$${template} --output text --query 'experimentTemplate.id' 2>&1 | tee -a $${OUTPUT}",
    "done",
    ]
  )
  filename        = "${path.cwd}/fis-create-experiment-templates.sh"
  file_permission = "0700"
}

resource "local_file" "delete-templates" {
  content = join("\n", [
    "#!/bin/bash -ex",
    "OUTPUT='.fis_cli_result'",
    "while read id; do",
    "  aws fis delete-experiment-template --id $${id} --output text --query 'experimentTemplate.id' 2>&1 > /dev/null",
    "done < $${OUTPUT}",
    "rm $${OUTPUT}",
    ]
  )
  filename        = "${path.cwd}/fis-delete-experiment-templates.sh"
  file_permission = "0700"
}
