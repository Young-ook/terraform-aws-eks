### Amazon EMR virtual cluster

# Need to update aws-auth configmap with,
#
#    - rolearn: arn:aws:iam::{AWS_ACCOUNT_ID}:role/AWSServiceRoleForAmazonEMRContainers
#      username: emr-containers
#
# and also, create role and role mapping on the target namespace
# for more details, https://docs.aws.amazon.com/emr/latest/EMR-on-EKS-DevelopmentGuide/setting-up-cluster-access.html
#
# `eksctl` provides a command that creates the required RBAC resources for EMR,
# and updates the aws-auth ConfigMap to bind the role with the SLR for EMR.
#

resource "local_file" "eksctl" {
  content = templatefile(join("/", [path.module, "templates", "eksctl-config.tpl"]), {
    aws_region = module.aws.region.name
    eks_name   = lookup(var.container_providers, "id")
    namespace  = lookup(var.container_providers, "namespace", local.default_emr_container_provider["namespace"])
  })
  filename        = join("/", [path.module, "eksctl-config.yaml"])
  file_permission = "0600"
}

resource "null_resource" "eksctl" {
  depends_on = [local_file.eksctl]
  provisioner "local-exec" {
    command = "eksctl create iamidentitymapping -f ${path.module}/eksctl-config.yaml"
    environment = {
      CLUSTER_NAME = lookup(var.container_providers, "id")
      SERVICE_NAME = lookup(var.container_providers, "service_name", local.default_emr_container_provider["service_name"])
      NAMESPACE    = lookup(var.container_providers, "namespace", local.default_emr_container_provider["namespace"])
    }
  }
}

resource "aws_emrcontainers_virtual_cluster" "emr" {
  depends_on = [null_resource.eksctl]
  name       = module.frigga.name
  tags       = merge(var.tags, local.default-tags)

  container_provider {
    id   = lookup(var.container_providers, "id")
    type = lookup(var.container_providers, "type", local.default_emr_container_provider["type"])

    info {
      eks_info {
        namespace = lookup(var.container_providers, "namespace", local.default_emr_container_provider["namespace"])
      }
    }
  }
}

### security/policy
resource "aws_iam_role" "emrjob" {
  name = module.frigga.name
  tags = merge(var.tags, local.default-tags)
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "elasticmapreduce.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "emrjob" {
  policy_arn = aws_iam_policy.emrjob.id
  role       = aws_iam_role.emrjob.name
}

resource "aws_iam_policy" "emrjob" {
  name   = module.frigga.name
  tags   = merge(var.tags, local.default-tags)
  policy = templatefile("${path.module}/templates/emrjob-policy.tpl", {})
}
