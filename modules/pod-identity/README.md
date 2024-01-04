# EKS Pod Identity

[EKS Pod Identities](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html) provide the ability to manage credentials for your applications, similar to the way that Amazon EC2 instance profiles provide credentials to Amazon EC2 instances. Instead of creating and distributing your AWS credentials to the containers or using the Amazon EC2 instance's role, you associate an IAM role with a Kubernetes service account and configure your Pods to use the service account. Each EKS Pod Identity association maps a role to a service account in a namespace in the specified cluster. If you have the same application in multiple clusters, you can make identical associations in each cluster without modifying the trust policy of the role.

## Setup
### Prerequisites
This module requires *terraform*. If you don't have the terraform tool in your environment, go to the main [page](https://github.com/Young-ook/terraform-aws-eks) of this repository and follow the installation instructions. Also, this EKS Pod Identity requires EKS Pod Identity Agent. Please make sure that the agents are installed on your EKS cluster. Once the agents are installed, you can see the new DaemonSet:
```
kubectl get pods -l app.kubernetes.io/instance=eks-pod-identity-agent -n kube-system
```
```
NAME                           READY   STATUS    RESTARTS   AGE
eks-pod-identity-agent-k469t   1/1     Running   0          3h58m
eks-pod-identity-agent-lvw6h   1/1     Running   0          3h58m
eks-pod-identity-agent-pzjgl   1/1     Running   0          3h58m
```

### Quickstart
EKS Pod Identity feature is available on new Amazon EKS Kubernetes version 1.24 clusters. Please make sure your EKS cluster version is 1.24 or higher to enable EKS Pod Identity agent on your EKS cluster for IAM role mapping with (Kubernetes) service accounts. You can see [EKS Pod Identity cluster versions](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html#pod-id-cluster-versions) for more information.
```
module "pod-identity" {
  source = "Young-ook/eks/aws//modules/pod-identity"
  identities = [
    {
      namespace      = "karpenter"
      serviceaccount = "karpenter-sa"
    },
  ]
}
```
Run terraform:
```
terraform init
terraform apply
```

## Clean up
Run terraform:
```
terraform destroy
```

## Additional Resources
- [Amazon EKS Pod Identity simplifies IAM permissions for applications on Amazon EKS clusters](https://aws.amazon.com/blogs/aws/amazon-eks-pod-identity-simplifies-iam-permissions-for-applications-on-amazon-eks-clusters/)
