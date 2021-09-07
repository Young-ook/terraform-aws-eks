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

### systems manager document for fault injection simulator experiment

resource "aws_ssm_document" "disk-stress" {
  name            = "FIS-Run-Disk-Stress"
  tags            = merge(local.default-tags, var.tags)
  document_format = "YAML"
  document_type   = "Command"
  content         = file("${path.module}/templates/disk-stress.yaml")
}

### fault injection simulator experiment templates

locals {
  target_vpc           = module.vpc.vpc.id
  target_role          = module.eks.role.arn
  target_asg           = module.eks.cluster.data_plane.managed_node_groups.sockshop.resources.0.autoscaling_groups.0.name
  target_eks_nodes     = module.eks.cluster.data_plane.managed_node_groups.sockshop.arn
  stop_condition_alarm = aws_cloudwatch_metric_alarm.cpu.arn
}

resource "local_file" "cpu-stress" {
  content = templatefile("${path.module}/templates/cpu-stress.tpl", {
    region = var.aws_region
    alarm  = aws_cloudwatch_metric_alarm.cpu.arn
    role   = aws_iam_role.fis-run.arn
  })
  filename        = "${path.module}/.fis/cpu-stress.json"
  file_permission = "0600"
}

resource "local_file" "network-latency" {
  content = templatefile("${path.module}/templates/network-latency.tpl", {
    region = var.aws_region
    alarm  = local.stop_condition_alarm
    role   = aws_iam_role.fis-run.arn
  })
  filename        = "${path.module}/.fis/network-latency.json"
  file_permission = "0600"
}

resource "random_integer" "az" {
  min = 0
  max = length(var.azs) - 1
}

resource "local_file" "throttle-ec2-api" {
  content = templatefile("${path.module}/templates/throttle-ec2-api.tpl", {
    asg_role = local.target_role
    alarm    = local.stop_condition_alarm
    role     = aws_iam_role.fis-run.arn
  })
  filename        = "${path.module}/.fis/throttle-ec2-api.json"
  file_permission = "0600"
}

resource "local_file" "terminate-eks-nodes" {
  content = templatefile("${path.module}/templates/terminate-eks-nodes.tpl", {
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

  })
  filename        = "${path.module}/.fis/terminate-eks-nodes.json"
  file_permission = "0600"
}

resource "local_file" "disk-stress" {
  content = templatefile("${path.module}/templates/disk-stress.tpl", {
    doc_arn = aws_ssm_document.disk-stress.arn
    alarm   = aws_cloudwatch_metric_alarm.disk.arn
    role    = aws_iam_role.fis-run.arn
  })
  filename        = "${path.module}/.fis/disk-stress.json"
  file_permission = "0600"
}

resource "local_file" "create-templates" {
  content = join("\n", [
    "#!/bin/bash",
    "OUTPUT='.fis_cli_result'",
    "TEMPLATES=('cpu-stress.json' 'network-latency.json' 'throttle-ec2-api.json' 'terminate-eks-nodes.json' 'disk-stress.json')",
    "for template in $${TEMPLATES[@]}; do",
    "  aws fis create-experiment-template --region ${var.aws_region} --cli-input-json file://$${template} --output text --query 'experimentTemplate.id' 2>&1 | tee -a $${OUTPUT}",
    "done",
    ]
  )
  filename        = "${path.module}/.fis/fis-create-experiment-templates.sh"
  file_permission = "0600"
}

resource "null_resource" "create-templates" {
  depends_on = [
    local_file.cpu-stress,
    local_file.network-latency,
    local_file.throttle-ec2-api,
    local_file.terminate-eks-nodes,
    local_file.create-templates,
  ]
  provisioner "local-exec" {
    when    = create
    command = "cd ${path.module}/.fis && bash fis-create-experiment-templates.sh"
  }
}

resource "local_file" "delete-templates" {
  content = join("\n", [
    "#!/bin/bash",
    "OUTPUT='.fis_cli_result'",
    "while read id; do",
    "  aws fis delete-experiment-template --region ${var.aws_region} --id $${id} --output text --query 'experimentTemplate.id' 2>&1 > /dev/null",
    "done < $${OUTPUT}",
    "rm $${OUTPUT}",
    ]
  )
  filename        = "${path.module}/.fis/fis-delete-experiment-templates.sh"
  file_permission = "0600"
}

resource "null_resource" "delete-templates" {
  depends_on = [
    local_file.cpu-stress,
    local_file.network-latency,
    local_file.throttle-ec2-api,
    local_file.terminate-eks-nodes,
    local_file.delete-templates,
  ]
  provisioner "local-exec" {
    when    = destroy
    command = "cd ${path.module}/.fis && bash fis-delete-experiment-templates.sh"
  }
}
