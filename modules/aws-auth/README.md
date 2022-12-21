# AWS-AUTH configamp for Amazon IAM and Kubernetes RBAC mapping

```
provider "kubernetes" {
  host                   = module.eks.kubeauth["host"]
  token                  = module.eks.kubeauth["token"]
  cluster_ca_certificate = module.eks.kubeauth["ca"]
}

### aws auth
module "aws-auth" {
  source = "Young-ook/eks/aws//modules/aws-auth"
  aws_auth_roles = [
    {
      rolearn = "role_arn_you_want_to_add"
      groups  = ["system:masters"]
    },
  ]
}
```
