# Amazon EKS (Elastic Kubernetes Service)
[Amazon EKS](https://aws.amazon.com/eks/) is a fully managed Kubernetes service. Customers trust EKS to run their most sensitive and mission critical applications because of its security, reliability, and scalability.

* This module will create an EKS cluster on AWS. It will have a control plane and you can register multiple heterogeneous node groups as data plane.
* This module will give you a utility bash script to set up a kubernetes configuration file to access the EKS cluster.
* This module has several sub-modules to deploy kubernetes controllers and utilities using helm provider.

## Examples
- [Amazon EKS Autoscaling](https://github.com/Young-ook/terraform-aws-eks/blob/main/examples/autoscaling)
- [Amazon EKS on AWS Fargate](https://github.com/Young-ook/terraform-aws-eks/blob/main/examples/fargate)
- [Amazon EKS on AWS Graviton](https://github.com/Young-ook/terraform-aws-eks/blob/main/examples/arm64)
- [Amazon EKS with Spot Instances](https://github.com/Young-ook/terraform-aws-eks/blob/main/examples/spot)
- [Amazon ECR](https://github.com/Young-ook/terraform-aws-eks/blob/main/examples/ecr)
- [AWS Fault Injection Simulator with AWS Systems Manager](https://github.com/Young-ook/terraform-aws-ssm/blob/main/examples/fis)
- [AWS Fault Injection Simulator with Amazon EKS](https://github.com/Young-ook/terraform-aws-eks/blob/main/examples/fis)
- [AWS Load Balancer Controller](https://github.com/Young-ook/terraform-aws-eks/blob/main/examples/lb)

## Getting started
### AWS CLI
Follow the official guide to install and configure profiles.
- [AWS CLI Installation](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
- [AWS CLI Configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html)

### Terraform
Infrastructure Engineering team is using terraform to build and manage infrastucure for DevOps. And we have a plan to migrate cloudformation termplate to terraform.

To install Terraform, find the appropriate package (https://www.terraform.io/downloads.html) for your system and download it. Terraform is packaged as a zip archive and distributed as a single binary. Install Terraform by unzipping it and moving it to a directory included in your system's `PATH`. The [tfenv](https://github.com/tfutils/tfenv) is very useful solution.

And there is an another option for easy install.
```
brew install tfenv
```
You can use this utility to make it ease to install and switch terraform binaries in your workspace like below.
```
tfenv install 0.12.18
tfenv use 0.12.18
```
Also this tool is helpful to upgrade terraform v0.12. It is a major release focused on configuration language improvements and thus includes some changes that you'll need to consider when upgrading. But the version 0.11 and 0.12 are very different. So if some codes are written in older version and others are in 0.12 it would be great for us to have nice tool to support quick switching of version.
```
tfenv list
tfenv use 0.12.18
tfenv use 0.11.14
tfenv install latest
tfenv use 0.12.18
```

### Kubernetes CLI
Here is a simple way to install the kubernetes command line tool on your environment if you are on macOS.
```
brew install kubernetes-cli
```

For more information about kubernetes tools, please visit this [page](https://kubernetes.io/docs/tasks/tools/) and follow the **kubectl** instructions if you want to install tools.

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
terraform init
terraform apply
```
## Generate kubernetes config
This terraform module provides users with a shell script that extracts the kubeconfig file of the EKS cluster. When users run the terraform init command in their workspace, the script is downloaded with the terraform module from the terraform registry. User can see how to run this script in terraform output after terraform apply command completes successfully. Using this script, users can easily obtain a kubeconfig file. So, they can use this kubeconfig file for access to the EKS cluster (with Spinnaker). The original script is here [update-kubeconfig.sh](https://github.com/Young-ook/terraform-aws-eks/blob/main/script/update-kubeconfig.sh) and users can check out the details of the script.

**[Important]** Before you run this script you must configure your local environment to have proper permission to get the credentials from EKS cluster on your AWS account whatever you are using aws-cli or aws-vault.

## IAM Role for Service Account
After then you will see the created EKS cluster and node groups and IAM role. For more information about configuration of service account mapping for IAM role in Kubernetes, please check out the [IAM Role for Service Accounts](https://github.com/Young-ook/terraform-aws-eks/blob/main/modules/iam-role-for-serviceaccount/README.md)

# Known Issues
## Unauthorized
You might get an error message when this module tries to create a `aws-auth` configuration map for a new EKS cluster. When prompted, re-apply the terraform configuration. Here is an example error message:
```
module.eks.kubernetes_config_map.aws-auth[0]: Creating...

Error: Unauthorized

  on .terraform/modules/eks/main.tf line 341, in resource "kubernetes_config_map" "aws-auth":
 341: resource "kubernetes_config_map" "aws-auth" {
```

## Configmap already exist
If you are trying to replace a managed nodegroup with a (self-managed) nodegroup, you may get an error message as this module tries to generate the `aws-auth` config map. This is because the managed nodegroup resource does not delete the `aws-auth` configmap when it is removed, but the self-managed nodegroup needs the `aws-auth` configmap for node registration, which causes a conflict. When prompted, delete exsiting `aws-auth` configmap using kubectl and retry the terraform apply command. Here is an example error message:
```
module.eks.kubernetes_config_map.aws-auth[0]: Creating...

Error: configmaps "aws-auth" already exists

  on .terraform/modules/eks/main.tf line 343, in resource "kubernetes_config_map" "aws-auth":
 343: resource "kubernetes_config_map" "aws-auth" {
```
