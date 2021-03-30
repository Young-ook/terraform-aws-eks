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
Follow [these](https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html) instructions

## Pushing a Helm chart
Follow [these](https://docs.aws.amazon.com/AmazonECR/latest/userguide/push-oci-artifact.html) instructions

## VPC Endpoints
You can improve the security posture of your VPC by configuring Amazon ECR to use an interface VPC endpoint. VPC endpoints are powered by AWS PrivateLink, a technology that enables you to privately access Amazon ECR APIs through private IP addresses. AWS PrivateLink restricts all network traffic between your VPC and Amazon ECR to the Amazon network. You don't need an internet gateway, a NAT device, or a virtual private gateway.

Before you configure VPC endpoints for Amazon ECR, be aware of the following considerations.

* To allow your Amazon ECS tasks that use the EC2 launch type to pull private images from Amazon ECR, ensure that you also create the interface VPC endpoints for Amazon ECS. For more information, see [Interface VPC Endpoints (AWS PrivateLink)](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/vpc-endpoints.html) in the Amazon Elastic Container Service Developer Guide.

* Amazon ECS tasks using the Fargate launch type and platform version 1.3.0 or earlier only require the **com.amazonaws.*region*.ecr.dkr** Amazon ECR VPC endpoint and the Amazon S3 gateway endpoint to take advantage of this feature.

* Amazon ECS tasks using the Fargate launch type and platform version 1.4.0 or later require both the **com.amazonaws.*region*.ecr.dkr** and **com.amazonaws.*region*.ecr.api** Amazon ECR VPC endpoints as well as the Amazon S3 gateway endpoint to take advantage of this feature.

* Amazon ECS tasks using the Fargate launch type that pull container images from Amazon ECR can restrict access to the specific VPC their tasks use and to the VPC endpoint the service uses by adding condition keys to the task execution IAM role for the task. For more information, see Optional IAM Permissions for Fargate Tasks Pulling Amazon ECR Images over Interface Endpoints in the Amazon Elastic Container Service Developer Guide.

For more default, please refer to this user guide [Amazon ECR interface VPC Endpoints](https://docs.aws.amazon.com/AmazonECR/latest/userguide/vpc-endpoints.html)

### Using VPC endpoint policies to control Amazon ECR access
To improve the security of network between AWS managed container registry and customer's VPC, In January 2019, AWS announced support for AWS PrivateLink on Amazon ECR. When you enable AWS PrivateLink for Amazon ECR, VPC endpoints appear as elastic network interfaces with a private IP address inside your VPC. For more details on how AWS PrivateLink works on Amazon ECR, please visit this [blog post](https://aws.amazon.com/blogs/compute/setting-up-aws-privatelink-for-amazon-ecs-and-amazon-ecr/).

![VPC Endpoints](https://github.com/Young-ook/terraform-aws-eks/blob/main/images/ecr-vpc-endpoints.png)

Here is example to apply custom policies on the VPC endpoints for more specific traffic control. Please read this [blog](https://aws.amazon.com/blogs/containers/using-vpc-endpoint-policies-to-control-amazon-ecr-access/), if you want to know how to do.
