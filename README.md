# Amazon EKS (Elastic Kubernetes Service)
[Amazon EKS](https://aws.amazon.com/eks/) is a fully managed Kubernetes service. Customers trust EKS to run their most sensitive and mission critical applications because of its security, reliability, and scalability.

* This module will create an EKS cluster on AWS. It will have a control plane and you can register multiple heterogeneous node groups as data plane.
* This module will give you a utility bash script to set up a kubernetes configuration file to access the EKS cluster.
* This module has several sub-modules to deploy kubernetes controllers and utilities using helm provider.

## Examples
- [Amazon EKS](https://github.com/Young-ook/terraform-aws-eks/blob/main/examples/complete/README.md)
- [Amazon EKS on AWS Fargate](https://github.com/Young-ook/terraform-aws-eks/blob/main/examples/fargate/README.md)
- [Amazon EKS on AWS Graviton](https://github.com/Young-ook/terraform-aws-eks/blob/main/examples/arm64/README.md)

## Quickstart
### Setup
```hcl
module "eks" {
  source  = "Young-ook/eks/aws"
  name    = "eks"
  tags    = { env = "test" }
}
```
Run terraform:
```
$ terraform init
$ terraform apply
```

### Generate kubernetes config
This terraform module will give you a shell script to get kubeconfig file of an EKS cluster. You will find the [update-kubeconfig.sh](https://github.com/Young-ook/terraform-aws-eks/blob/main/script/update-kubeconfig.sh) script in the `script` directory of this repository. You can get the kubeconfig file with credentials to access your EKS cluster using this script. For more detail of how to use this, please refer to the help message of the script.

[Important] Before you run this script you must configure your local environment to have proper permission to get the credentials from EKS cluster on your AWS account whatever you are using aws-cli or aws-vault.

## IAM Role for Service Account
After then you will see the created EKS cluster and node groups and IAM role. For more information about configuration of service account mapping for IAM role in Kubernetes, please check out the [IAM Role for Service Accounts](https://github.com/Young-ook/terraform-aws-eks/blob/main/modules/iam-role-for-serviceaccount/README.md)

# Known Issues
## Unauthorized
You might get an error message when this module tries to create a `aws-auth` configuration map for a new EKS cluster. When prompted, reapply the terraform composition. Here is an example error message:
```
module.eks.kubernetes_config_map.aws-auth[0]: Creating...

Error: Unauthorized

  on .terraform/modules/eks/main.tf line 341, in resource "kubernetes_config_map" "aws-auth":
 341: resource "kubernetes_config_map" "aws-auth" {
```
