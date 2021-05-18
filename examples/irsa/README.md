# IAM Role for Service Account (IRSA)
## Setup
[This](https://github.com/Young-ook/terraform-aws-eks/blob/main/examples/irsa/main.tf) is the example of terraform configuration file to create a managed EKS on your AWS account. Check out and apply it using terraform command.

Run terraform:
```
$ terraform init
$ terraform apply
```
Also you can use the `-var-file` option for customized paramters when you run the terraform plan/apply command.
```
$ terraform plan -var-file tc1.tfvars
$ terraform apply -var-file tc1.tfvars
```

## Generate kubernetes config
To update kubernetes configuration and put it to local space for kubectl access, folow [this](https://github.com/Young-ook/terraform-aws-eks/blob/main/README.md#generate-kubernetes-config) instructions.

## IAM Role for Service Accounts
After then you will see the created EKS cluster and node groups. And also, you will see IAM role for Service Account resource. For more information about configuration of service account mapping for IAM role in Kubernetes, please refer to the [IRSA](https://github.com/Young-ook/terraform-aws-eks/blob/main/modules/iam-role-for-serviceaccount/)

### Create an service account
When the kubernetes nodes are up, you have to create an service account with name that you defined in terraform configuration. Following example is a manifest to create a service account with annotation.
```
cat  << EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: s3-readonly
  namespace: default
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::12xxxxxxxx87:role/irsa-eks-irsa-s3-readonly
EOF
```
Or, you can create a service account using kubernetes cli. You will find out full command from terraform output after it's done like below.
```
kubecli = kubectl -n default create sa s3-readonly && kubectl -n default annotate sa s3-readonly eks.amazonaws.com/role-arn=arn:aws:iam::12xxxxxxxx87:role/irsa-eks-irsa-s3-readonly
```
Copy and run:
```
$ kubectl -n default create sa s3-readonly && kubectl -n default annotate sa s3-readonly eks.amazonaws.com/role-arn=arn:aws:iam::12xxxxxxxx87:role/irsa-eks-irsa-s3-readonly
serviceaccount/s3-readonly created
serviceaccount/s3-readonly annotated
```

### Run test application
Successfully created service account, you can deploy test application. This will run a pod to try to describe s3 bucket on your AWS account using aws-cli.
```
cat  << EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: aws-cli
spec:
  template:
    metadata:
      labels:
        app: aws-cli
    spec:
      serviceAccountName: s3-readonly
      containers:
      - name: aws-cli
        image: amazon/aws-cli:latest
        args: ["s3", "ls"]
      restartPolicy: Never
EOF
```

### Check nodes are ready
All previous steps are finished, check if a node is `Ready`:
```
$ kubectl get nodes
NAME                                                   STATUS   ROLES    AGE   VERSION
fargate-ip-10-1-1-48.ap-northeast-2.compute.internal   Ready    <none>   30s   v1.19.6-eks-e91815
```

Get into the pod and run aws-cli to see if retrives list of Amazon S3 buckets:
```
$ kubectl logs -l app=aws-cli
```

## Clean up
### Remove test application
Remove the running pods from kubernetes nodes.
```
$ kubectl delete deployment aws-cli
```

### Delete infrastructure
Run terraform:
```
$ terraform destroy
```
Don't forget you have to use the `-var-file` option when you run terraform destroy command to delete the aws resources created with extra variable files.
```
$ terraform destroy -var-file tc1.tfvars
```
