## managed kubernetes cluster

data "aws_partition" "current" {}

## features
locals {
  node_groups_enabled         = (var.node_groups != null ? ((length(var.node_groups) > 0) ? true : false) : false)
  managed_node_groups_enabled = (var.managed_node_groups != null ? ((length(var.managed_node_groups) > 0) ? true : false) : false)
  fargate_enabled             = (var.fargate_profiles != null ? ((length(var.fargate_profiles) > 0) ? true : false) : false)
}

## control plane (cp)
# security/policy
resource "aws_iam_role" "cp" {
  name = format("%s-cp", local.name)
  tags = merge(local.default-tags, var.tags)
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = format("eks.%s", data.aws_partition.current.dns_suffix)
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks-cluster" {
  policy_arn = format("arn:%s:iam::aws:policy/AmazonEKSClusterPolicy", data.aws_partition.current.partition)
  role       = aws_iam_role.cp.id
}

resource "aws_iam_role_policy_attachment" "eks-service" {
  policy_arn = format("arn:%s:iam::aws:policy/AmazonEKSServicePolicy", data.aws_partition.current.partition)
  role       = aws_iam_role.cp.id
}

resource "aws_eks_cluster" "cp" {
  name     = format("%s", local.name)
  role_arn = aws_iam_role.cp.arn
  version  = var.kubernetes_version
  tags     = merge(local.default-tags, var.tags)

  enabled_cluster_log_types = var.enabled_cluster_log_types

  vpc_config {
    subnet_ids = local.subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster,
    aws_iam_role_policy_attachment.eks-service,
  ]
}

## node groups (ng)
# security/policy
resource "aws_iam_role" "ng" {
  count = local.node_groups_enabled || local.managed_node_groups_enabled ? 1 : 0
  name  = format("%s-ng", local.name)
  tags  = merge(local.default-tags, var.tags)
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = [format("ec2.%s", data.aws_partition.current.dns_suffix)]
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_instance_profile" "ng" {
  count = local.node_groups_enabled || local.managed_node_groups_enabled ? 1 : 0
  name  = format("%s-ng", local.name)
  role  = aws_iam_role.ng.0.name
}

resource "aws_iam_role_policy_attachment" "eks-ng" {
  count      = local.node_groups_enabled || local.managed_node_groups_enabled ? 1 : 0
  policy_arn = format("arn:%s:iam::aws:policy/AmazonEKSWorkerNodePolicy", data.aws_partition.current.partition)
  role       = aws_iam_role.ng.0.name
}

resource "aws_iam_role_policy_attachment" "eks-cni" {
  count      = local.node_groups_enabled || local.managed_node_groups_enabled ? 1 : 0
  policy_arn = format("arn:%s:iam::aws:policy/AmazonEKS_CNI_Policy", data.aws_partition.current.partition)
  role       = aws_iam_role.ng.0.name
}

resource "aws_iam_role_policy_attachment" "ecr-read" {
  count      = local.node_groups_enabled || local.managed_node_groups_enabled ? 1 : 0
  policy_arn = format("arn:%s:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly", data.aws_partition.current.partition)
  role       = aws_iam_role.ng.0.name
}

resource "aws_iam_role_policy_attachment" "ssm-managed" {
  count      = (local.node_groups_enabled || local.managed_node_groups_enabled) && var.enable_ssm ? 1 : 0
  policy_arn = format("arn:%s:iam::aws:policy/AmazonSSMManagedInstanceCore", data.aws_partition.current.partition)
  role       = aws_iam_role.ng.0.name
}

resource "aws_iam_role_policy_attachment" "extra" {
  for_each   = { for key, val in var.policy_arns : key => val }
  policy_arn = each.value
  role       = aws_iam_role.ng[0].name
}

## self-managed node groups

data "aws_ami" "eks" {
  for_each    = { for ng in var.node_groups : ng.name => ng }
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = [format(length(regexall("ARM|GPU$", lookup(each.value, "ami_type", "AL2_x86_64"))) > 0 ? "amazon-eks-*-node-%s-*" : "amazon-eks-node-%s-*", var.kubernetes_version)]
  }
  filter {
    name   = "architecture"
    values = [length(regexall("ARM", lookup(each.value, "ami_type", "AL2_x86_64"))) > 0 ? "arm64" : "x86_64"]
  }
}

data "template_cloudinit_config" "ng" {
  for_each      = { for ng in var.node_groups : ng.name => ng }
  base64_encode = true
  gzip          = false

  part {
    content_type = "text/x-shellscript"
    content      = <<-EOT
    #!/bin/bash
    ${var.enable_ssm ? "yum install -y amazon-ssm-agent\nsystemctl enable amazon-ssm-agent\nsystemctl start amazon-ssm-agent" : ""}
    EOT
  }

  part {
    content_type = "text/x-shellscript"
    content      = <<-EOT
    #!/bin/bash
    set -ex
    /etc/eks/bootstrap.sh ${aws_eks_cluster.cp.name} --kubelet-extra-args '--node-labels=eks.amazonaws.com/nodegroup-image=${data.aws_ami.eks[each.key].id},eks.amazonaws.com/nodegroup=${join("-", [aws_eks_cluster.cp.name, each.key])}' --b64-cluster-ca ${aws_eks_cluster.cp.certificate_authority.0.data} --apiserver-endpoint ${aws_eks_cluster.cp.endpoint}
    EOT
  }
}

resource "aws_launch_template" "ng" {
  for_each      = { for ng in var.node_groups : ng.name => ng }
  name          = format("eks-%s", uuid())
  tags          = merge(local.default-tags, local.eks-tag, var.tags)
  image_id      = data.aws_ami.eks[each.key].id
  user_data     = base64encode(data.template_cloudinit_config.ng[each.key].rendered)
  instance_type = lookup(each.value, "instance_type", "t3.medium")

  iam_instance_profile {
    arn = aws_iam_instance_profile.ng.0.arn
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = lookup(each.value, "disk_size", "20")
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

  network_interfaces {
    security_groups       = [aws_eks_cluster.cp.vpc_config.0.cluster_security_group_id]
    delete_on_termination = true
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(local.eks-owned-tag, var.tags)
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}

resource "aws_autoscaling_group" "ng" {
  for_each              = { for ng in var.node_groups : ng.name => ng }
  name                  = format("eks-%s", uuid())
  vpc_zone_identifier   = local.subnet_ids
  max_size              = lookup(each.value, "max_size", 3)
  min_size              = lookup(each.value, "min_size", 1)
  desired_capacity      = lookup(each.value, "desired_size", 1)
  force_delete          = true
  protect_from_scale_in = false
  termination_policies  = ["Default"]
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.ng[each.key].id
        version            = aws_launch_template.ng[each.key].latest_version
      }

      dynamic "override" {
        for_each = lookup(each.value, "instances_override", [])
        content {
          instance_type     = lookup(override.value, "instance_type", null)
          weighted_capacity = lookup(override.value, "weighted_capacity", null)
        }
      }
    }

    dynamic "instances_distribution" {
      for_each = { for key, val in each.value : key => val if key == "instances_distribution" }
      content {
        on_demand_allocation_strategy            = lookup(instances_distribution.value, "on_demand_allocation_strategy", null)
        on_demand_base_capacity                  = lookup(instances_distribution.value, "on_demand_base_capacity", null)
        on_demand_percentage_above_base_capacity = lookup(instances_distribution.value, "on_demand_percentage_above_base_capacity", null)
        spot_allocation_strategy                 = lookup(instances_distribution.value, "spot_allocation_strategy", null)
        spot_instance_pools                      = lookup(instances_distribution.value, "spot_instance_pools", null)
        spot_max_price                           = lookup(instances_distribution.value, "spot_max_price", null)
      }
    }
  }

  dynamic "tag" {
    for_each = merge(
      local.eks-tag,
      {
        "eks:nodegroup-name" = join("-", [aws_eks_cluster.cp.name, each.key])
      }
    )
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity, name]
  }

  depends_on = [
    aws_iam_role.ng,
    aws_iam_role_policy_attachment.eks-ng,
    aws_iam_role_policy_attachment.eks-cni,
    aws_iam_role_policy_attachment.ecr-read,
    aws_launch_template.ng,
  ]
}

## managed node groups

# Render a multi-part cloud-init config making use of the part
# above, and other source files
data "template_cloudinit_config" "mng" {
  for_each      = { for ng in var.managed_node_groups : ng.name => ng }
  base64_encode = true
  gzip          = false

  # Main cloud-config configuration file.
  part {
    content_type = "text/x-shellscript"
    content      = <<-EOT
    #!/bin/bash
    ${var.enable_ssm ? "yum install -y amazon-ssm-agent\nsystemctl enable amazon-ssm-agent\nsystemctl start amazon-ssm-agent" : ""}
    EOT
  }
}

resource "aws_launch_template" "mng" {
  for_each  = { for ng in var.managed_node_groups : ng.name => ng }
  name      = format("eks-%s", uuid())
  tags      = merge(local.default-tags, local.eks-tag, var.tags)
  user_data = data.template_cloudinit_config.mng[each.key].rendered

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = lookup(each.value, "disk_size", "20")
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(local.eks-owned-tag, var.tags)
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}

resource "aws_eks_node_group" "ng" {
  for_each        = { for ng in var.managed_node_groups : ng.name => ng }
  cluster_name    = aws_eks_cluster.cp.name
  node_group_name = join("-", [aws_eks_cluster.cp.name, each.key])
  node_role_arn   = aws_iam_role.ng.0.arn
  subnet_ids      = local.subnet_ids
  ami_type        = lookup(each.value, "ami_type", "AL2_x86_64") # available values ["AL2_x86_64", "AL2_x86_64_GPU", "AL2_ARM_64"]
  instance_types  = [lookup(each.value, "instance_type", "m5.xlarge")]
  version         = aws_eks_cluster.cp.version
  tags            = merge(local.default-tags, var.tags)

  scaling_config {
    max_size     = lookup(each.value, "max_size", 3)
    min_size     = lookup(each.value, "min_size", 1)
    desired_size = lookup(each.value, "desired_size", 1)
  }

  launch_template {
    id      = aws_launch_template.mng[each.key].id
    version = aws_launch_template.mng[each.key].latest_version
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config[0].desired_size]
  }

  depends_on = [
    aws_iam_role.ng,
    aws_iam_role_policy_attachment.eks-ng,
    aws_iam_role_policy_attachment.eks-cni,
    aws_iam_role_policy_attachment.ecr-read,
  ]
}

## fargate
# security/policy
resource "aws_iam_role" "fargate" {
  count = local.fargate_enabled ? 1 : 0
  name  = format("%s-fargate", local.name)
  tags  = merge(local.default-tags, var.tags)
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = [format("eks-fargate-pods.%s", data.aws_partition.current.dns_suffix)]
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks-fargate" {
  count      = local.fargate_enabled ? 1 : 0
  policy_arn = format("arn:%s:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy", data.aws_partition.current.partition)
  role       = aws_iam_role.fargate.0.name
}

resource "aws_eks_fargate_profile" "fargate" {
  for_each               = { for ng in var.fargate_profiles : ng.name => ng }
  cluster_name           = aws_eks_cluster.cp.name
  fargate_profile_name   = each.key
  pod_execution_role_arn = aws_iam_role.fargate.0.arn
  subnet_ids             = local.subnet_ids
  tags                   = merge(local.default-tags, var.tags)

  selector {
    namespace = lookup(each.value, "namespace", "default")
    labels    = lookup(each.value, "labels", null)
  }

  depends_on = [
    aws_iam_role.fargate,
    aws_iam_role_policy_attachment.eks-fargate,
  ]
}

resource "aws_iam_openid_connect_provider" "oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
  url             = aws_eks_cluster.cp.identity.0.oidc.0.issuer
}

locals {
  oidc = {
    arn = aws_iam_openid_connect_provider.oidc.arn
    url = replace(aws_iam_openid_connect_provider.oidc.url, "https://", "")
  }
}

provider "kubernetes" {
  host                   = aws_eks_cluster.cp.endpoint
  token                  = data.aws_eks_cluster_auth.cp.token
  cluster_ca_certificate = base64decode(aws_eks_cluster.cp.certificate_authority.0.data)
}

resource "time_sleep" "wait" {
  count           = ((local.managed_node_groups_enabled || local.fargate_enabled) ? 0 : (local.node_groups_enabled ? 1 : 0))
  create_duration = "180s"
  depends_on = [
    aws_eks_cluster.cp,
    aws_eks_node_group.ng,
    aws_autoscaling_group.ng,
  ]
}

resource "kubernetes_config_map" "aws-auth" {
  count      = ((local.managed_node_groups_enabled || local.fargate_enabled) ? 0 : (local.node_groups_enabled ? 1 : 0))
  depends_on = [time_sleep.wait]
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode(
      [{
        rolearn  = element(compact(aws_iam_role.ng.*.arn), 0)
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      }],
    )
  }
}
