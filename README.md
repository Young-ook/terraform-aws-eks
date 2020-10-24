# Amazon EKS (Elastic Kubernetes Service)
[Amazon EKS](https://aws.amazon.com/eks/) is a fully managed Kubernetes service. Customers trust EKS to run their most sensitive and mission critical applications because of its security, reliability, and scalability.

## Assumptions
* You want to create an EKS cluster on AWS. This module will create an EKS control plane and data plane.
* This module will give you a utility bash script to configure kubernetes configuration file to access the EKS cluster.

## Examples
- [Quickstart Example](https://github.com/Young-ook/terraform-aws-eks/blob/main/README.md#quickstart)
- [Complete Example](https://github.com/Young-ook/terraform-aws-eks/blob/main/examples/complete/README.md#example)

## Quickstart
### Setup
```hcl
module "eks" {
  source  = "Young-ook/eks/aws"
  version = "~> 1.0"

  name    = "eks"
  tags    = { "env" = "test" }
}
```
Run terraform:
```
terraform init
terraform apply
```

### Generate kubernetes config
This terraform module will give you a shell script to get kubeconfig file of an EKS cluster. You will find the [update-kubeconfig.sh](https://github.com/Young-ook/terraform-aws-eks/blob/main/script/update-kubeconfig.sh) script in the `script` directory of this repository. You can get the kubeconfig file with credentials to access your EKS cluster using this script. For more detail of how to use this, please refer to the help message of the script.

[Important] Before you run this script you must configure your local environment to have proper permission to get the credentials from EKS cluster on your AWS account whatever you are using aws-cli or aws-vault.

## IAM Role for Service Account
After then you will see the created EKS cluster and node groups and IAM role. For more information about configuration of service account mapping for IAM role in Kubernetes, please check out the [IAM Role for Service Accounts](https://github.com/Young-ook/terraform-aws-eks/blob/main/modules/iam-role-for-serviceaccount/README.md)
