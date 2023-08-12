# Amazon EKS Add-on

An [add-on](https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html) is software that provides supporting operational capabilities to Kubernetes applications, but is not specific to the application. This includes software like observability agents or Kubernetes drivers that allow the cluster to interact with underlying AWS resources for networking, compute, and storage. Add-on software is typically built and maintained by the Kubernetes community, cloud providers like AWS, or third-party vendors. Amazon EKS automatically installs self-managed add-ons such as the Amazon VPC CNI, kube-proxy, and CoreDNS for every cluster. You can change the default configuration of the add-ons and update them when desired.

For detailed steps when using the AWS Management Console, AWS CLI, and eksctl, see the topics for the following add-ons:
- [Amazon VPC CNI](https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html)
- [CoreDNS](https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html)
- [kube-proxy](https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html)
- [Amazon EBS CSI](https://docs.aws.amazon.com/eks/latest/userguide/managing-ebs-csi.html)
- [ADOT](https://docs.aws.amazon.com/eks/latest/userguide/opentelemetry.html)

## Setup
### Prerequisites
This module requires *terraform*. If you don't have the terraform tool in your environment, go to the main [page](https://github.com/Young-ook/terraform-aws-eks) of this repository and follow the installation instructions.

### Quickstart
```
module "eks-addons" {
  source     = "Young-ook/eks/aws//modules/eks-addons"
  addons = [
    {
      name     = "vpc-cni"
      eks_name = var.eks.cluster.name
    },
  ]
}
```
Run terraform:
```
terraform init
terraform apply
```
