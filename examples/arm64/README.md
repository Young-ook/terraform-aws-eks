# Amazon EKS on Graviton
## Setup
[This](https://github.com/Young-ook/terraform-aws-eks/blob/main/examples/arm64/main.tf) is the example of terraform configuration file to create a managed EKS with ARM64 architecture based node groups on your AWS account. Check out and apply it using terraform command.

Run terraform:
```
$ terraform init
$ terraform apply
```
Also you can use the `-var-file` option for customized paramters when you run the terraform plan/apply command.
```
$ terraform plan -var-file=default.tfvars
$ terraform apply -var-file=default.tfvars
```

## Verify
After provisioning of EKS cluster, you can describe nodes using kubectl and check out your node groups are running on ARM64 architecture.
```
$ kubectl describe no
System Info:
  OS Image:                   Amazon Linux 2
  Operating System:           linux
  Architecture:               arm64
  Container Runtime Version:  docker://19.3.6
  Kubelet Version:            v1.17.11-eks-xxxxyy
  Kube-Proxy Version:         v1.17.11-eks-xxxxyy
```

## Clean up
Run terraform:
```
$ terraform destroy
```
Don't forget you have to use the `-var-file` option when you run terraform destroy command to delete the aws resources created with extra variable files.
```
$ terraform destroy -var-file=default.tfvars
```
