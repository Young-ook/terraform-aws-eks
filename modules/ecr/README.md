# Amazon ECR (Elastic Container Registry)
[Amazon Elastic Container Registry](https://aws.amazon.com/ecr/) is a fully managed container registry that makes it easy to store, manage, share, and deploy your container images and artifacts anywhere. Amazon ECR eliminates the need to operate your own container repositories or worry about scaling the underlying infrastructure. Amazon ECR hosts your images in a highly available and high-performance architecture, allowing you to reliably deploy images for your container applications. You can share container software privately within your organization or publicly worldwide for anyone to discover and download. This module will create an ECR on AWS.

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

## Pushing a Docker image
Follow the instructions from [this](https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html)

## Pushing a Helm chart
Follow the instructions from [this](https://docs.aws.amazon.com/AmazonECR/latest/userguide/push-oci-artifact.html)
