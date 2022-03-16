# Karpenter
[Karpenter](https://github.com/aws/karpenter) is an open-source node provisioning project built for Kubernetes. Its goal is to improve the efficiency and cost of running workloads on Kubernetes clusters. Check out the [docs](https://karpenter.sh/) to learn more.

## Examples
- [Introducing Karpenter](https://aws.amazon.com/blogs/aws/introducing-karpenter-an-open-source-high-performance-kubernetes-cluster-autoscaler/)
- [Implement autoscaling with Karpenter](https://www.eksworkshop.com/beginner/085_scaling_karpenter/)

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
