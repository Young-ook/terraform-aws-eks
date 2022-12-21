## kubernetes aws-auth configmap

data "kubernetes_config_map" "aws-auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
}

locals {
  merged_aws_auth = {
    mapRoles    = yamlencode(concat(yamldecode(data.kubernetes_config_map.aws-auth.data.mapRoles), var.aws_auth_roles))
    mapUsers    = yamlencode(var.aws_auth_users)
    mapAccounts = yamlencode(var.aws_auth_accounts)
  }
}

resource "kubernetes_config_map_v1_data" "aws-auth" {
  depends_on = [data.kubernetes_config_map.aws-auth]
  force      = true
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
  data = local.merged_aws_auth
}
