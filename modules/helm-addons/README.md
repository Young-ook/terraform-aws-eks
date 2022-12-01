# Helm add-ons

[Helm](https://helm.sh/) is a tool for managing Charts. Charts are packages of pre-configured Kubernetes resources. Helm helps you manage Kubernetes applications — Helm Charts help you define, install, and upgrade even the most complex Kubernetes application. Charts are easy to create, version, share, and publish — so start using Helm and stop the copy-and-paste.

For detailed steps when using terraform, see the topics for the following add-ons:
* [Cluster Autoscaler](https://github.com/Young-ook/terraform-aws-eks/tree/main/examples/autoscaling)

## Setup
```hcl
module "eks" {
  source       = "Young-ook/eks/aws"
  name         = "eks"
}

provider "helm" {
  kubernetes {
    host                   = module.eks.helmconfig.host
    token                  = module.eks.helmconfig.token
    cluster_ca_certificate = base64decode(module.eks.helmconfig.ca)
  }
}

module "helm_addons" {
  source = "Young-ook/eks/aws//modules/helm_addons"
  addons = [
    {
      repository     = "https://aws.github.io/eks-charts"
      name           = "appmesh-controller"
      chart_name     = "appmesh-controller"
      namespace      = "aws-addons"
      serviceaccount = "appmesh-controller"
      values = {
        "region"           = var.aws_region
        "tracing.enabled"  = true
        "tracing.provider" = "x-ray"
      }
      oidc = module.eks.oidc
      policy_arns = [
        format("arn:%s:iam::aws:policy/AWSCloudMapFullAccess", module.aws.partition.partition),
        format("arn:%s:iam::aws:policy/AWSAppMeshFullAccess", module.aws.partition.partition),
      ]
    },
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

Run the terraform code to make a change on your environment.
```sh
terraform init
terraform apply
```

# Clean up
Run terraform:
```sh
terraform destroy
```

# Additional Resources
- [Helm add-ons](https://docs.aws.amazon.com/prescriptive-guidance/latest/containers-provision-eks-clusters-terraform/helm-add-ons.html)