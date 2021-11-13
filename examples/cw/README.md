# Amazon CloudWatch Container Insights
Use [CloudWatch Container Insights](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/ContainerInsights.html) to collect, aggregate, and summarize metrics and logs from your containerized applications and microservices. It automatically collects metrics for many resources, such as CPU, memory, disk, and network. It also provides diagnostic information, such as container restart failures, to help you isolate issues and resolve them quickly. You can also set CloudWatch alarms on metrics that Container Insights collects.

![aws-cw-container-insights](../../images/aws-cw-container-insights.png)

## Download example
Download this example on your workspace
```sh
git clone https://github.com/Young-ook/terraform-aws-eks
cd terraform-aws-eks/examples/cw
```

## Setup
[This](https://github.com/Young-ook/terraform-aws-eks/blob/main/examples/cw/main.tf) is the example of terraform configuration file to create a managed EKS on your AWS account and install Amazon CloudWatch Container Insights agents using Helm chart to the EKS cluster. Check out and apply it using terraform command.

Run terraform:
```sh
terraform init
terraform apply
```
Also you can use the `-var-file` option for customized paramters when you run the terraform plan/apply command.
```sh
terraform plan -var-file tc1.tfvars
terraform apply -var-file tc1.tfvars
```

### Update kubeconfig
Update and download kubernetes config file to local. You can see the bash command like below after terraform apply is complete. The output looks like below. Copy and run it to save the kubernetes configuration file to your local workspace. And export it as an environment variable to apply to the terminal.
```sh
bash -e .terraform/modules/eks/script/update-kubeconfig.sh -r ap-northeast-2 -n eks-cw -k kubeconfig
export KUBECONFIG=kubeconfig
```

## Clean up
Run terraform:
```
terraform destroy
```
Or if you only want to remove all resources of CloudWatch Container Insights from the EKS clsuter, you can run terraform destroy command with `-target` option:
```
terraform destroy -target module.cw
```
Don't forget you have to use the `-var-file` option when you run terraform destroy command to delete the aws resources created with extra variable files.
```
terraform destroy -var-file tc1.tfvars
```
