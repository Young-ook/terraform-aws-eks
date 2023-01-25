[[English](README.md)] [[한국어](README.ko.md)]

# FinOps
This is a blueprint example helps you compose complete EKS clusters that are fully bootstrapped with the operational software and cost optimization tools for FinOps. With this example, you describe the configuration for the desired state of your EKS environment, such as the control plane, worker nodes, and Kubernetes add-ons, as an Infrastructure as Code (IaC) template/blueprint. Once a blueprint is configured, you can use it to stamp out consistent environments across multiple AWS accounts and Regions using your automation workflow tool, such as Jenkins, CodePipeline. Also, you can use EKS Blueprint to easily bootstrap an EKS cluster with Amazon EKS add-ons as well as a wide range of popular open-source add-ons, including Prometheus, Karpenter, Nginx, Traefik, Fluent Bit, Keda, and more. This blueprint also helps you implement relevant security controls needed to operate workloads from multiple teams in the same cluster.

## Setup
### Download
Download this example on your workspace
```
git clone https://github.com/Young-ook/terraform-aws-eks
cd terraform-aws-eks/examples/finops
```

Then you are in **finops** directory under your current workspace. There is an exmaple that shows how to use terraform configurations to create and manage an EKS cluster and Addon utilities on your AWS account. Check out and apply it using terraform command. If you don't have the terraform and kubernetes tools in your environment, go to the main [page](https://github.com/Young-ook/terraform-aws-eks) of this repository and follow the installation instructions before you move to the next step.

Run terraform:
```
terraform init
terraform apply
```
Also you can use the *-var-file* option for customized paramters when you run the terraform plan/apply command.
```
terraform plan -var-file fixture.tc1.tfvars
terraform apply -var-file fixture.tc1.tfvars
```

### Update kubeconfig
We need to get kubernetes config file for access the cluster that we've made using terraform. After terraform apply, you will see the bash command on the outputs. For more details, please refer to the [user guide](https://github.com/Young-ook/terraform-aws-eks#generate-kubernetes-config).

## Kubernetes Utilities
### Cloudforet
[Cloudforet](https://github.com/cloudforet-io) is a multi-cloud and hybrid-cloud management platform. Cloudforet helps you to see your scattered cloud resources over multiple cloud providers at a glence. And it also allows you to analyze your costs easily and optimize resources based on cost data. By using Cloudforet, you can control expenses and prevent overspendings with budget management feature for finops.

### Kubecost

## Clean up
To destroy all infrastrcuture, run terraform:
```
terraform destroy
```

If you don't want to see a confirmation question, you can use quite option for terraform destroy command
```
terraform destroy --auto-approve
```

**[DON'T FORGET]** You have to use the *-var-file* option when you run terraform destroy command to delete the aws resources created with extra variable files.
```
terraform destroy -var-file fixture.tc1.tfvars
```

# Known Issues
## Unauthorized
Cloudforet (SpaceONE) requires two namespaces, **spaceone** and **root-supervisor**. So, when you run this example for the first time, you might get the following error message.
```
module.helm-addons.helm_release.chart["spaceone"]: Still creating... [1m10s elapsed]
╷
│ Warning: Helm release "spaceone" was created but has a failed status. Use the `helm` command to investigate the error, correct it, then run Terraform again.
│
│   with module.helm-addons.helm_release.chart["spaceone"],
│   on .terraform/modules/helm-addons/modules/helm-addons/main.tf line 2, in resource "helm_release" "chart":
│    2: resource "helm_release" "chart" {
│
╵
╷
│ Error: namespaces "root-supervisor" not found
│
│   with module.helm-addons.helm_release.chart["spaceone"],
│   on .terraform/modules/helm-addons/modules/helm-addons/main.tf line 2, in resource "helm_release" "chart":
│    2: resource "helm_release" "chart" {
│
╵
```
If you see these errors on the first try, follow the steps to create the **root-supervisor** namespace in the just created EKS cluster. 1) First update the kubernetes config file in your local workspace. Run kubeconfig output variable from `terraform output`. For more details, please refer to the [user guide](https://github.com/Young-ook/terraform-aws-eks#generate-kubernetes-config). 2) Then, create namespace using kubernetes command line interface. 3) Run again terraform apply.
```
kubectl create ns root-supervisor
```

# Additional Resources
## Cloudforet (SpaceONE)
- [SpaceONE launchpad](https://github.com/cloudforet-io/launchpad)
