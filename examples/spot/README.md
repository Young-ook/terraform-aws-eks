# Amazon EKS with Spot Instances
Amazon EC2 Spot Instances let you take advantage of unused EC2 capacity in the AWS cloud. Spot Instances are available at up to a 90% discount compared to On-Demand prices; however, can be interrupted via Spot Instance interruptions, a two-minute warning before Amazon EC2 stops or terminates the instance. The AWS Node Termination Handler makes it easy for users to take advantage of the cost savings and performance boost offered by EC2 Spot Instances in their Kubernetes clusters while gracefully handling EC2 Spot Instance terminations. The AWS Node Termination Handler provides a connection between termination requests from AWS to Kubernetes nodes, allowing graceful draining and termination of nodes that receive interruption notifications. The termination handler uses the Kubernetes API to initiate drain and cordon actions on a node that is targeted for termination.
For more details, please visit [this](https://github.com/Young-ook/terraform-aws-eks/blob/main/modules/node-termination-handler/)

## Download example
Download this example on your workspace
```sh
git clone https://github.com/Young-ook/terraform-aws-eks
cd terraform-aws-eks/examples/spot
```

## Setup
[This](https://github.com/Young-ook/terraform-aws-eks/blob/main/examples/spot/main.tf) is the example of terraform configuration file to create a managed EKS with Spot Instances on your AWS account. Check out and apply it using terraform command.

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

## Clean up
Run terraform:
```
terraform destroy
```
Don't forget you have to use the `-var-file` option when you run terraform destroy command to delete the aws resources created with extra variable files.
```
terraform destroy -var-file default.tfvars
```
