# Amazon EKS with Spot Instances
## Setup
[This](https://github.com/Young-ook/terraform-aws-eks/blob/main/examples/spot/main.tf) is the example of terraform configuration file to create a managed EKS with Spot Instances on your AWS account. Check out and apply it using terraform command.

Run terraform:
```
$ terraform init
$ terraform apply
```
Also you can use the `-var-file` option for customized paramters when you run the terraform plan/apply command.
```
$ terraform plan -var-file default.tfvars
$ terraform apply -var-file default.tfvars
```

After then you will see the created EKS cluster and node groups. For more information about configuration of service account mapping for IAM role in Kubernetes, please check out the [IRSA](https://github.com/Young-ook/terraform-aws-eks/tree/main/modules/iam-role-for-serviceaccount/)

## Clean up
Run terraform:
```
$ terraform destroy
```
Don't forget you have to use the `-var-file` option when you run terraform destroy command to delete the aws resources created with extra variable files.
```
$ terraform destroy -var-file default.tfvars
```
