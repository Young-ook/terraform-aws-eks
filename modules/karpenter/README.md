# Karpenter
[Karpenter](https://github.com/aws/karpenter) is an open-source node provisioning project built for Kubernetes. Its goal is to improve the efficiency and cost of running workloads on Kubernetes clusters. Check out the [docs](https://karpenter.sh/) to learn more.

## Examples
- [Amazon EKS Autoscaling](https://github.com/Young-ook/terraform-aws-eks/blob/main/examples/autoscaling/)

## Quickstart
### Setup
This is a terraform module to deploy Helm chart for Karpenter on your EKS cluster.
```hcl
module "eks" {
  source                     = "Young-ook/eks/aws"
  name                       = "eks"
}

provider "helm" {
  kubernetes {
    host                   = module.eks.helmconfig.host
    token                  = module.eks.helmconfig.token
    cluster_ca_certificate = base64decode(module.eks.helmconfig.ca)
  }
}

module "karpenter" {
  source       = "Young-ook/eks/aws//modules/kerpenter"
  cluster_name = module.eks.cluster.name
  oidc         = module.eks.oidc
}
```
Run the terraform code to make a change on your environment.
```
terraform init
terraform apply
```

### Verify
#### Check container status
