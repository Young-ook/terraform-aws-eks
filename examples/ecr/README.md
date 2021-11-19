# Amazon ECR
[Amazon Elastic Container Registry](https://aws.amazon.com/ecr/) is a fully managed container registry that makes it easy to store, manage, share, and deploy your container images and artifacts anywhere.
This is an example on how to create ECR on the AWS. If you want know more details about ECR terraform module, please check out [this](https://github.com/Young-ook/terraform-aws-eks/blob/main/modules/ecr).

## Download example
Download this example on your workspace
```sh
git clone https://github.com/Young-ook/terraform-aws-eks
cd terraform-aws-eks/examples/ecr
```

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

### VPC Endpoints
To improve the security of the VPC, a user has to configure Amazon ECR to use an interface VPC endpoint. For more details, please refer to [this](https://github.com/Young-ook/terraform-aws-eks/blob/main/modules/ecr).

* Amazon ECS tasks using the Fargate launch type and platform version 1.3.0 or earlier only require the com.amazonaws.region.ecr.dkr Amazon ECR VPC endpoint and the Amazon S3 gateway endpoints.
* Amazon ECS tasks using the Fargate launch type and platform version 1.4.0 or later require both the com.amazonaws.region.ecr.dkr and com.amazonaws.region.ecr.api Amazon ECR VPC endpoints and the Amazon S3 gateway endpoints.

### Update kubeconfig
Update and download kubernetes config file to local. You can see the bash command like below after terraform apply is complete. The output looks like below. Copy and run it to save the kubernetes configuration file to your local workspace. And export it as an environment variable to apply to the terminal.

```
bash -e .terraform/modules/eks/script/update-kubeconfig.sh -r ap-northeast-2 -n eks-ecr -k kubeconfig
export KUBECONFIG=kubeconfig
```

### Register Artifacts
In this example, after terraform apply, you will see generated shell script that it will help you build and register container images. Find `build.sh` on your local workspace and run it.

```
bash docker-build.sh
```

This terraform example also creates kubernetes manifest file to deploy simple application that it was built in the `build` script.
```
kubectl apply -f hello-nodejs.yaml
```

## Clean up
Run terraform:
```
terraform destroy
```
Don't forget you have to use the `-var-file` option when you run terraform destroy command to delete the aws resources created with extra variable files.
```
terraform destroy -var-file default.tfvars
```
