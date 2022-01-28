# Amazon EKS Add-ons
This is an example on how to create and update add-ons on your EKS cluster. If you want know more details about Add-on terraform module, please check out [this](https://github.com/Young-ook/terraform-aws-eks/blob/main/modules/addon).

## Download example
Download this example on your workspace
```sh
git clone https://github.com/Young-ook/terraform-aws-eks
cd terraform-aws-eks/examples/addon
```

## Setup
[This](https://github.com/Young-ook/terraform-aws-eks/blob/main/examples/addon/main.tf) is the example of terraform configuration file to create multiple add-ons on your EKS cluster. Check out and apply it using terraform command.

If you don't have the terraform and kubernetes tools in your environment, go to the main [page](https://github.com/Young-ook/terraform-aws-eks) of this repository and follow the installation instructions.

Run terraform:
```
terraform init
terraform apply
```
Also you can use the `-var-file` option for customized paramters when you run the terraform plan/apply command.
```
terraform plan -var-file tc1.tfvars
terraform apply -var-file tc1.tfvars
```

### Update kubeconfig
Update and download kubernetes config file to local. You can see the bash command like below after terraform apply is complete. The output looks like below. Copy and run it to save the kubernetes configuration file to your local workspace. And export it as an environment variable to apply to the terminal.

```
bash -e .terraform/modules/eks/script/update-kubeconfig.sh -r ap-northeast-2 -n eks-addon -k kubeconfig
export KUBECONFIG=kubeconfig
```

## Clean up
Run terraform:
```
terraform destroy
```
Don't forget you have to use the `-var-file` option when you run terraform destroy command to delete the aws resources created with extra variable files.
```
terraform destroy -var-file tc1.tfvars
```
