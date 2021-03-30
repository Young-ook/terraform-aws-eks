# Amazon ECR

## Setup
[This](https://github.com/Young-ook/terraform-aws-eks/blob/main/examples/ecr/main.tf) is the example of terraform configuration file to create an ECR (Elastic Container Registry) on your AWS account. Check out and apply it using terraform command.

Run terraform:
```
terraform init
terraform apply
```
Also you can use the `-var-file` option for customized paramters when you run the terraform plan/apply command.
```
terraform plan -var-file default.tfvars
terraform apply -var-file default.tfvars
```

## VPC Endpoints
To improve the security of the VPC, a user has to configure Amazon ECR to use an interface VPC endpoint. For more details, please refer to [this](https://github.com/Young-ook/terraform-aws-eks/blob/main/modules/ecr).

* Amazon ECS tasks using the Fargate launch type and platform version 1.3.0 or earlier only require the com.amazonaws.region.ecr.dkr Amazon ECR VPC endpoint and the Amazon S3 gateway endpoints.
* Amazon ECS tasks using the Fargate launch type and platform version 1.4.0 or later require both the com.amazonaws.region.ecr.dkr and com.amazonaws.region.ecr.api Amazon ECR VPC endpoints and the Amazon S3 gateway endpoints.

## Register Artifacts
To register and release the artifacts from your build system, please check out [this](https://github.com/Young-ook/terraform-aws-eks/blob/main/modules/ecr) for more details.

## Clean up
Run terraform:
```
$ terraform destroy
```
Don't forget you have to use the `-var-file` option when you run terraform destroy command to delete the aws resources created with extra variable files.
```
$ terraform destroy -var-file default.tfvars
```
