# AWS App Mesh
## Setup
[This](https://github.com/Young-ook/terraform-aws-eks/blob/main/examples/app-mesh/main.tf) is the example of terraform configuration file to create a managed EKS on your AWS account and install AWS App Mesh controller using Helm chart to the EKS cluster. Check out and apply it using terraform command.

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

## AWS App Mesh
[AWS App Mesh](https://aws.amazon.com/app-mesh/) is a service mesh that provides application-level networking to make it easy for your services to communicate with each other across multiple types of compute infrastructure. App Mesh gives end-to-end visibility and high-availability for your applications.

Run terraform. After provisioning of EKS cluster, you can check the helm chart deployment using kubectl.
```
$ kubectl -n appmesh-system get all
NAME                                             READY   STATUS    RESTARTS   AGE
pod/eks-am-appmesh-controller-656d6d6c48-h2zhv   1/1     Running   0          18m

NAME                                                TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
service/eks-am-appmesh-controller-webhook-service   ClusterIP   10.100.106.244   <none>        443/TCP   18m

NAME                                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/eks-am-appmesh-controller   1/1     1            1           18m

NAME                                                   DESIRED   CURRENT   READY   AGE
replicaset.apps/eks-am-appmesh-controller-656d6d6c48   1         1         1       18m
```

## Clean up

Run terraform:
```
$ terraform destroy
```
Or if you only want to remove all resources of App Mesh Controller from the EKS clsuter, you can run terraform destroy command with `-target` option:
```
$ terraform destroy -target module.app-mesh
```
Don't forget you have to use the `-var-file` option when you run terraform destroy command to delete the aws resources created with extra variable files.
```
$ terraform destroy -var-file default.tfvars
```
