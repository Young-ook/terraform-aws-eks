# AWS Load Balancer Controller
AWS Load Balancer Controller is a controller to help manage Elastic Load Balancers for a Kubernetes cluster.
- It satisfies Kubernetes Ingress resources by provisioning Application Load Balancers.
- It satisfies Kubernetes Service resources by provisioning Network Load Balancers.
The AWS Load Balancer Controller makes it easy for users to take advantage of the loadbalancer management. For more details, please visit [this](https://github.com/kubernetes-sigs/aws-load-balancer-controller)

## Download example
Download this example on your workspace
```sh
git clone https://github.com/Young-ook/terraform-aws-eks
cd terraform-aws-eks/examples/lb
```

## Setup
[This](https://github.com/Young-ook/terraform-aws-eks/blob/main/examples/lb/main.tf) is the example of terraform configuration file to create an EKS cluster and to install load balancer controller on it.

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
bash -e .terraform/modules/eks/script/update-kubeconfig.sh -r ap-northeast-2 -n eks-lbc -k kubeconfig
export KUBECONFIG=kubeconfig
```

## Verify
All steps are finished, check that there are pods that are `Ready` in `kube-system` namespace:
Ensure the `aws-load-balancer-controller` pod is generated and running:

```sh
kubectl get deployment -n kube-system aws-load-balancer-controller
```
Output:
```
NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
aws-load-balancer-controller   2/2     2            2           84s
```

For more details, please refer to [this](https://github.com/Young-ook/terraform-aws-eks/blob/main/modules/lb-controller) module description.

## Application
You can run the sample application on a cluster. Deploy the game 2048 as a sample application to verify that the AWS load balancer controller creates an AWS ALB as a result of the Ingress object.
```sh
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/examples/2048/2048_full.yaml
```

After a few minutes, verify that the Ingress resource was created with the following command. Describe ingress resource using kubectl. You will see the amazon resource name (ARN) of the generated application load balancer (ALB). Copy the address from output and open on the web browser.
```sh
kubectl -n game-2048 get ing
```
Output:
```
NAME           CLASS    HOSTS   ADDRESS                                                                        PORTS   AGE
ingress-2048   <none>   *       k8s-game2048-ingress2-9e5ab32c61-1003956951.ap-northeast-2.elb.amazonaws.com   80      29s
```

![aws-ec2-lbc-game-2048](../../images/aws-ec2-lbc-game-2048.png)

## Clean up
### Remove Application
Delete the example from kubernetes:
```sh
kubectl delete -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/examples/2048/2048_full.yaml
```

### Remove Infrastructure
Run terraform to destroy infrastructure:
```sh
terraform destroy
```
Don't forget you have to use the `-var-file` option when you run terraform destroy command to delete the aws resources created with extra variable files.
```sh
terraform destroy -var-file tc1.tfvars
```
