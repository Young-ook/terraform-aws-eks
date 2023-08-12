# Helm add-ons

[Helm](https://helm.sh/) is a tool for managing Charts. Charts are packages of pre-configured Kubernetes resources. Helm helps you manage Kubernetes applications — Helm Charts help you define, install, and upgrade even the most complex Kubernetes application. Charts are easy to create, version, share, and publish — so start using Helm and stop the copy-and-paste. For detailed steps when using terraform, see the [EKS Blueprint](https://github.com/Young-ook/terraform-aws-eks/tree/main/examples/blueprint) example. 

## Setup
### Prerequisites
This module requires *terraform*. If you don't have the terraform tool in your environment, go to the main [page](https://github.com/Young-ook/terraform-aws-eks) of this repository and follow the installation instructions.

### Quickstart
```
provider "helm" {
  kubernetes {
    host                   = module.eks.kubeauth.host
    token                  = module.eks.kubeauth.token
    cluster_ca_certificate = module.eks.kubeauth.ca
  }
}

module "helm_addons" {
  source = "Young-ook/eks/aws//modules/helm_addons"
  addons = [
    {
      repository     = "https://kubernetes-sigs.github.io/metrics-server/"
      name           = "metrics-server"
      chart_name     = "metrics-server"
      namespace      = "kube-system"
      serviceaccount = "metrics-server"
      values = {
        "args[0]" = "--kubelet-preferred-address-types=InternalIP"
      }
    },
  ]
}
```
Run terraform:
```
terraform init
terraform apply
```

# Clean up
Run terraform:
```
terraform destroy
```

# Additional Resources
- [Helm add-ons and Kubernetes Cluster Autoscaler](https://docs.aws.amazon.com/prescriptive-guidance/latest/containers-provision-eks-clusters-terraform/helm-add-ons.html)
