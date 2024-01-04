### aws partitions
module "aws" {
  source = "Young-ook/spinnaker/aws//modules/aws-partitions"
}

### security/policy
resource "aws_iam_role" "pid" {
  for_each = { for k, v in var.identities : k => v }
  name     = module.frigga[each.key].name
  path     = var.path
  tags     = merge(local.default-tags, { Name = module.frigga[each.key].name }, var.tags)
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "sts:AssumeRole",
        "sts:TagSession",
      ]
      Effect = "Allow"
      Principal = {
        Service = [format("pods.eks.%s", module.aws.partition.dns_suffix)]
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "pid" {
  for_each = { for k, v in [for policy in chunklist(flatten(
    [
      for k, v in var.identities : setproduct(v.policy_arns, [k])
      if(length(lookup(v, "policy_arns", [])) > 0)
    ]), 2) :
    {
      arn  = policy[0]
      role = policy[1]
    }
  ] : k => v }
  policy_arn = each.value["arn"]
  role       = aws_iam_role.pid[each.value["role"]].id
}

resource "aws_eks_pod_identity_association" "pid" {
  for_each        = { for k, v in var.identities : k => v }
  tags            = merge(local.default-tags, { Name = module.frigga[each.key].name }, var.tags)
  cluster_name    = lookup(each.value, "eks_name")
  namespace       = lookup(each.value, "namespace", local.default_pod_identity_config.namespace)
  service_account = lookup(each.value, "serviceaccount", local.default_pod_identity_config.serviceaccount)
  role_arn        = aws_iam_role.pid[each.key].arn
}
