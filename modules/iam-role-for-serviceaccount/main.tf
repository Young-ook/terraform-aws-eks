locals {
  oidc_fully_qualified_subjects = format("system:serviceaccount:%s:%s", var.namespace, var.serviceaccount)
  oidc_url                      = trimprefix(var.oidc_url, "https://")
}

# security/policy
resource "aws_iam_role" "irsa" {
  count = var.enabled ? 1 : 0
  name  = format("%s", local.name)
  path  = "/"
  tags  = merge(local.default-tags, var.tags)
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = var.oidc_arn
      }
      Condition = {
        StringEquals = {
          "${local.oidc_url}:sub" = local.oidc_fully_qualified_subjects
        },
        StringEquals = {
          "${local.oidc_url}:aud" = "sts.amazonaws.com"
        }
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "irsa" {
  for_each   = var.enabled ? { for key, val in var.policy_arns : key => val } : {}
  policy_arn = each.value
  role       = aws_iam_role.irsa[0].name
}
