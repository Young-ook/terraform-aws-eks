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

## Application deployment for Hybrid-Architecture node groups
Amazon EKS customers can now run production workloads using Arm-based instances including the recently launched Amazon EC2 M6g, C6g, and R6g instances powered by AWS Graviton2 processors. [AWS Graviton](https://aws.amazon.com/ec2/graviton/) processors are custom built by Amazon Web Services using 64-bit ARM Neoverse cores to deliver the best price performance for you cloud workloads running on Amazon EC2.

The new general purpose (M6g), compute-optimized (C6g), and memory-optimized (R6g) instances deliver up to 40% better price/performance over comparable current generation x86-based instances for scale-out and Arm-based applications such as web servers, containerized microservices, caching fleets, and distributed data stores that are supported by the extensive Arm ecosystem. You can mix x86 and Arm based EC2 instances within a cluster, and easily evaluate Arm-based application in existing environments.

Create an EKS cluster with a mixed architecture based node groups. And run the command that you can see on the terraform output to get a kubeconfig file for cluster access. It should look like this: `bash -e .terraform/modules/eks/script/update-kubeconfig.sh -r us-west-2 -n eks-x86-arm64-tc2 -k kubeconfig`. For more detail of the script, please refer to the [Generate kubernetes config](https://github.com/Young-ook/terraform-aws-eks/blob/main/README.md#generate-kubernetes-config)

```
$ terraform apply -var-file tc2.tfvars
```
Edit and save a new deployment file (nginx.yaml) on your workspace and apply:
```
apiVersion: v1
kind: Service
metadata:
  name: my-nginx-svc
  labels:
    app: nginx
spec:
  ports:
  - port: 80
  selector:
    app: nginx
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-nginx
  labels:
    app: nginx
spec:
  replicas: 30
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
```
```
$ kubectl apply -f nginx.yaml
service/my-nginx-svc created
deployment.apps/my-nginx created
```

To verify that the nginx pods are running properly on the multiple architecture node groups, run describe command.
```
$ kubectl describe nodes
Name:               ip-172-xx-yx-xxx.us-west-2.compute.internal
                    beta.kubernetes.io/instance-type=m6g.medium
                    eks.amazonaws.com/nodegroup=eks-x86-arm64-tc2
                    kubernetes.io/arch=arm64
                    kubernetes.io/os=linux
CreationTimestamp:  Fri, 20 Nov 2020 12:52:26 +0900
System Info:
  Operating System:           linux
  Architecture:               arm64
  Container Runtime Version:  docker://19.3.6
  Kubelet Version:            v1.17.12-eks-xxxxyy
  Kube-Proxy Version:         v1.17.12-eks-xxxxyy
Non-terminated Pods:          (8 in total)
  Namespace                   Name                         CPU Requests  CPU Limits  Memory Requests  Memory Limits  AGE
  ---------                   ----                         ------------  ----------  ---------------  -------------  ---
  default                     my-nginx-xxxxyyyyww-bqpfk    0 (0%)        0 (0%)      0 (0%)           0 (0%)         3m2s
  default                     my-nginx-xxxxyyyyww-fzpfb    0 (0%)        0 (0%)      0 (0%)           0 (0%)         3m2s
  default                     my-nginx-xxxxyyyyww-kqht5    0 (0%)        0 (0%)      0 (0%)           0 (0%)         3m2s
  default                     my-nginx-xxxxyyyyww-m5x25    0 (0%)        0 (0%)      0 (0%)           0 (0%)         3m2s
  default                     my-nginx-xxxxyyyyww-tcv92    0 (0%)        0 (0%)      0 (0%)           0 (0%)         3m2s
Events:                       <none>
Name:               ip-172-xx-yy-xxx.us-west-2.compute.internal
                    beta.kubernetes.io/instance-type=m5.large
                    eks.amazonaws.com/nodegroup=eks-x86-arm64-tc2
                    kubernetes.io/arch=amd64
                    kubernetes.io/os=linux
CreationTimestamp:  Fri, 20 Nov 2020 12:52:59 +0900
System Info:
  Operating System:           linux
  Architecture:               amd64
  Container Runtime Version:  docker://19.3.6
  Kubelet Version:            v1.17.12-eks-xxxxyy
  Kube-Proxy Version:         v1.17.12-eks-xxxxyy
Non-terminated Pods:          (28 in total)
  Namespace                   Name                         CPU Requests  CPU Limits  Memory Requests  Memory Limits  AGE
  ---------                   ----                         ------------  ----------  ---------------  -------------  ---
  default                     my-nginx-xxxxyyyyww-5wlvd    0 (0%)        0 (0%)      0 (0%)           0 (0%)         3m2s
  default                     my-nginx-xxxxyyyyww-626nn    0 (0%)        0 (0%)      0 (0%)           0 (0%)         3m2s
  default                     my-nginx-xxxxyyyyww-6h7nk    0 (0%)        0 (0%)      0 (0%)           0 (0%)         3m2s
  default                     my-nginx-xxxxyyyyww-dgppf    0 (0%)        0 (0%)      0 (0%)           0 (0%)         3m2s
  default                     my-nginx-xxxxyyyyww-fgp8r    0 (0%)        0 (0%)      0 (0%)           0 (0%)         3m2s
Events:                       <none>
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
