# Amazon ECR (Elastic Container Registry)
[Amazon Elastic Container Registry](https://aws.amazon.com/ecr/) is a fully managed container registry that makes it easy to store, manage, share, and deploy your container images and artifacts anywhere. Amazon ECR eliminates the need to operate your own container repositories or worry about scaling the underlying infrastructure. Amazon ECR hosts your images in a highly available and high-performance architecture, allowing you to reliably deploy images for your container applications. You can share container software privately within your organization or publicly worldwide for anyone to discover and download.

* You want to create an ECR and this module will create an ECR.

## Quickstart
### Setup
```hcl
module "ecr" {
  source  = "Young-ook/eks/aws//modules/ecr"
  name    = "example"
}
```
Run terraform:
```
terraform init
terraform apply
```
