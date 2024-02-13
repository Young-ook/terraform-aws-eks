## managed kubernetes cluster

## features
locals {
  node_groups_enabled         = (var.node_groups != null ? ((length(var.node_groups) > 0) ? true : false) : false)
  managed_node_groups_enabled = (var.managed_node_groups != null ? ((length(var.managed_node_groups) > 0) ? true : false) : false)
  fargate_enabled             = (var.fargate_profiles != null ? ((length(var.fargate_profiles) > 0) ? true : false) : false)
}

## control plane (cp)
# security/policy
resource "aws_iam_role" "cp" {
  name = join("-", [local.name, "cp"])
  tags = merge(local.default-tags, var.tags)
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = format("eks.%s", module.aws.partition.dns_suffix)
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks-cluster" {
  policy_arn = format("arn:%s:iam::aws:policy/AmazonEKSClusterPolicy", module.aws.partition.partition)
  role       = aws_iam_role.cp.id
}

resource "aws_eks_cluster" "cp" {
  name     = local.name
  role_arn = aws_iam_role.cp.arn
  version  = var.kubernetes_version
  tags     = merge(local.default-tags, var.tags)

  enabled_cluster_log_types = var.enabled_cluster_log_types

  vpc_config {
    subnet_ids = var.subnets
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster,
  ]
}

## node groups (ng)
# security/policy
resource "aws_iam_role" "ng" {
  for_each = local.node_groups_enabled || local.managed_node_groups_enabled ? toset(["enabled"]) : []
  name     = join("-", [local.name, "ng"])
  tags     = merge(local.default-tags, var.tags)
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = [format("ec2.%s", module.aws.partition.dns_suffix)]
      }
    }]
  })
}

resource "aws_iam_instance_profile" "ng" {
  for_each = local.node_groups_enabled || local.managed_node_groups_enabled ? toset(["enabled"]) : []
  name     = join("-", [local.name, "ng"])
  role     = aws_iam_role.ng["enabled"].name
}

resource "aws_iam_role_policy_attachment" "eks-ng" {
  for_each   = local.node_groups_enabled || local.managed_node_groups_enabled ? toset(["enabled"]) : []
  policy_arn = format("arn:%s:iam::aws:policy/AmazonEKSWorkerNodePolicy", module.aws.partition.partition)
  role       = aws_iam_role.ng["enabled"].name
}

resource "aws_iam_role_policy_attachment" "eks-cni" {
  for_each   = local.node_groups_enabled || local.managed_node_groups_enabled ? toset(["enabled"]) : []
  policy_arn = format("arn:%s:iam::aws:policy/AmazonEKS_CNI_Policy", module.aws.partition.partition)
  role       = aws_iam_role.ng["enabled"].name
}

resource "aws_iam_role_policy_attachment" "ecr-read" {
  for_each   = local.node_groups_enabled || local.managed_node_groups_enabled ? toset(["enabled"]) : []
  policy_arn = format("arn:%s:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly", module.aws.partition.partition)
  role       = aws_iam_role.ng["enabled"].name
}

resource "aws_iam_role_policy_attachment" "ssm-managed" {
  for_each   = (local.node_groups_enabled || local.managed_node_groups_enabled) && var.enable_ssm ? toset(["enabled"]) : []
  policy_arn = format("arn:%s:iam::aws:policy/AmazonSSMManagedInstanceCore", module.aws.partition.partition)
  role       = aws_iam_role.ng["enabled"].name
}

resource "aws_iam_role_policy_attachment" "ng-extra" {
  for_each   = (local.node_groups_enabled || local.managed_node_groups_enabled) ? { for k, v in var.policy_arns : k => v } : {}
  policy_arn = each.value
  role       = aws_iam_role.ng["enabled"].name
}

## bottlerocket
locals {
  bottlerocket_userdata = templatefile("${path.module}/templates/bottlerocket.tpl", {
    cluster_name                 = aws_eks_cluster.cp.name
    cluster_endpoint             = aws_eks_cluster.cp.endpoint
    cluster_ca_data              = aws_eks_cluster.cp.certificate_authority.0.data
    admin_container_enabled      = lookup(var.bottlerocket_config, "admin_container_enabled", local.default_bottlerocket_config.admin_container_enabled)
    admin_container_superpowered = lookup(var.bottlerocket_config, "admin_container_superpowered", local.default_bottlerocket_config.admin_container_superpowered)
    admin_container_source       = lookup(var.bottlerocket_config, "admin_container_source", local.default_bottlerocket_config.admin_container_source)
    control_container_enabled    = var.enable_ssm
  })
}

## self-managed node groups

data "aws_ami" "eks" {
  for_each    = { for ng in var.node_groups : ng.name => ng }
  owners      = ["amazon"]
  most_recent = true

  filter {
    name = "name"
    values = [
      format(length(regexall("^AL2", lookup(each.value, "ami_type", local.default_eks_config.ami_type))) > 0 ?
        (length(regexall("ARM|GPU$", lookup(each.value, "ami_type", local.default_eks_config.ami_type))) > 0 ? "amazon-eks-*-node-%s-*" : "amazon-eks-node-%s-*") :
        (length(regexall("^BOTTLEROCKET", lookup(each.value, "ami_type", local.default_eks_config.ami_type))) > 0 ? "bottlerocket-aws-k8s-%s-*" : "amazon-eks-node-%s-*")
      , var.kubernetes_version)
    ]
  }
  filter {
    name   = "architecture"
    values = [length(regexall("ARM", lookup(each.value, "ami_type", "AL2_x86_64"))) > 0 ? "arm64" : "x86_64"]
  }
}

data "cloudinit_config" "ng" {
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
    /etc/eks/bootstrap.sh ${aws_eks_cluster.cp.name} --kubelet-extra-args '--node-labels=eks.amazonaws.com/nodegroup-image=${data.aws_ami.eks[each.key].id},eks.amazonaws.com/nodegroup=${each.key}' --b64-cluster-ca ${aws_eks_cluster.cp.certificate_authority.0.data} --apiserver-endpoint ${aws_eks_cluster.cp.endpoint}
    EOT
  }
}

resource "aws_launch_template" "ng" {
  for_each      = { for ng in var.node_groups : ng.name => ng }
  name          = format("eks-%s", uuid())
  tags          = merge(local.default-tags, local.eks-tag, var.tags, lookup(each.value, "tags", {}))
  image_id      = data.aws_ami.eks[each.key].id
  instance_type = lookup(each.value, "instance_type", local.default_eks_config.instance_type)
  user_data = (
    length(regexall("^AL2", lookup(each.value, "ami_type", local.default_eks_config.ami_type))) > 0 ?
    data.cloudinit_config.ng[each.key].rendered :
    length(regexall("^BOTTLEROCKET", lookup(each.value, "ami_type", local.default_eks_config.ami_type))) > 0 ?
    base64encode(local.bottlerocket_userdata) :
    data.cloudinit_config.ng[each.key].rendered
  )

  iam_instance_profile {
    arn = aws_iam_instance_profile.ng["enabled"].arn
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = lookup(each.value, "disk_size", "20")
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

  metadata_options {
    http_tokens = "required"
  }

  network_interfaces {
    security_groups       = [aws_eks_cluster.cp.vpc_config.0.cluster_security_group_id]
    delete_on_termination = true
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(local.default-tags, local.eks-tag, var.tags, lookup(each.value, "tags", {}))
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}

resource "aws_autoscaling_group" "ng" {
  for_each              = { for ng in var.node_groups : ng.name => ng }
  name                  = format("eks-%s-%s", each.key, uuid())
  vpc_zone_identifier   = var.subnets
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
      { "eks:nodegroup-name" = join("-", [each.key]) },
      local.eks-tag,
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
    time_sleep.wait,
  ]
}

## managed node groups

# Render a multi-part cloud-init config making use of the part
# above, and other source files
data "cloudinit_config" "mng" {
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
  for_each = { for ng in var.managed_node_groups : ng.name => ng }
  name     = format("eks-%s", uuid())
  tags     = merge(local.default-tags, local.eks-tag, var.tags, lookup(each.value, "tags", {}))
  user_data = (
    length(regexall("^AL2", lookup(each.value, "ami_type", local.default_eks_config.ami_type))) > 0 ?
    data.cloudinit_config.mng[each.key].rendered :
    length(regexall("^BOTTLEROCKET", lookup(each.value, "ami_type", local.default_eks_config.ami_type))) > 0 ?
    base64encode(local.bottlerocket_userdata) :
    data.cloudinit_config.mng[each.key].rendered
  )

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = lookup(each.value, "disk_size", "20")
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

  metadata_options {
    http_tokens = "required"
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(local.default-tags, local.eks-tag, var.tags, lookup(each.value, "tags", {}))
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}

resource "aws_eks_node_group" "ng" {
  for_each        = { for ng in var.managed_node_groups : ng.name => ng }
  cluster_name    = aws_eks_cluster.cp.name
  node_group_name = each.key
  node_role_arn   = aws_iam_role.ng["enabled"].arn
  subnet_ids      = var.subnets
  ami_type        = lookup(each.value, "ami_type", local.default_eks_config.ami_type)
  capacity_type   = lookup(each.value, "capacity_type", local.default_eks_config.capacity_type)
  instance_types  = [lookup(each.value, "instance_type", local.default_eks_config.instance_type)]
  version         = aws_eks_cluster.cp.version
  tags            = merge(local.default-tags, var.tags, lookup(each.value, "tags", {}))

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
    aws_launch_template.mng,
    time_sleep.wait,
  ]
}

## fargate
# security/policy
resource "aws_iam_role" "fargate" {
  for_each = local.fargate_enabled ? toset(["enabled"]) : []
  name     = join("-", [local.name, "fargate"])
  tags     = merge(local.default-tags, var.tags)
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = [format("eks-fargate-pods.%s", module.aws.partition.dns_suffix)]
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks-fargate" {
  count      = local.fargate_enabled ? 1 : 0
  policy_arn = format("arn:%s:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy", module.aws.partition.partition)
  role       = aws_iam_role.fargate["enabled"].name
}

resource "aws_iam_role_policy_attachment" "fargate-extra" {
  for_each   = local.fargate_enabled ? { for k, v in var.policy_arns : k => v } : {}
  policy_arn = each.value
  role       = aws_iam_role.fargate["enabled"].name
}

resource "aws_eks_fargate_profile" "fargate" {
  for_each               = { for ng in var.fargate_profiles : ng.name => ng }
  cluster_name           = aws_eks_cluster.cp.name
  fargate_profile_name   = each.key
  pod_execution_role_arn = aws_iam_role.fargate["enabled"].arn
  subnet_ids             = var.subnets
  tags                   = merge(local.default-tags, var.tags, lookup(each.value, "tags", {}))

  selector {
    namespace = lookup(each.value, "namespace", "default")
    labels    = lookup(each.value, "labels", null)
  }

  depends_on = [
    aws_iam_role.fargate,
    aws_iam_role_policy_attachment.eks-fargate,
  ]
}

data "tls_certificate" "cert" {
  url = aws_eks_cluster.cp.identity.0.oidc.0.issuer
}

resource "aws_iam_openid_connect_provider" "oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = data.tls_certificate.cert.certificates[*].sha1_fingerprint
  url             = data.tls_certificate.cert.url
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
  create_duration = var.wait
  depends_on      = [aws_eks_cluster.cp, ]
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
