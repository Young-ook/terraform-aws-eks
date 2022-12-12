# IAM Role for Service Account with OIDC
With [IAM roles for service accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) on Amazon EKS clusters, you can associate an IAM role with a Kubernetes service account. This module creates a single IAM role which can be assumed by trusted resources using OpenID Connect federated users. For more information about creating OpenID Connect identity provider, please visit [this](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)

![aws-iam-role-for-sa](../../images/aws-iam-role-for-sa.png)

## Setup
### Create an IAM Role
The IAM roles for Service Accounts (IRSA) feature is available on new Amazon EKS Kubernetes version 1.14 clusters. Please make sure your EKS cluster version is 1.14 or higher to enable IAM roles for (Kubernetes) service accounts.
This is AWS documentation for [IRSA]( https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)
```
module "irsa" {
  source         = "Young-ook/eks/aws//modules/iam-role-for-serviceaccount"
  version        = "1.7.10"
  name           = join("-", ["irsa", var.name, "s3-readonly"])
  namespace      = "default"
  serviceaccount = "s3-readonly"
  oidc_url       = module.eks.oidc.url
  oidc_arn       = module.eks.oidc.arn
  policy_arns    = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
  tags           = var.tags
}
```

Modify the terraform configuration file to add the IRSA resources and Run the terraform code to make a change on your environment.
```
terraform init
terraform apply
```

### Create a service account
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

Or, you can create a service account using kubernetes cli. You will find out full command from terraform output after it's done like below. Copy and run:
```
kubectl -n default create sa s3-readonly && kubectl -n default annotate sa s3-readonly eks.amazonaws.com/role-arn=arn:aws:iam::12xxxxxxxx87:role/irsa-eks-irsa-s3-readonly
```
```
serviceaccount/s3-readonly created
serviceaccount/s3-readonly annotated
```

Ensure the *s3-readonly* is created.
```
kubectl get sa s3-readonly
```

### Verify
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
All previous steps are finished, check if a node is *Ready*:
```
kubectl get po
```

Get into the pod and run aws-cli to see if retrives list of Amazon S3 buckets:
```
kubectl logs -l app=aws-cli
```

## Clean up
### Remove test application
Remove the running pods from kubernetes nodes.
```
kubectl delete deployment aws-cli
```

### Delete infrastructure
Run terraform:
```
terraform destroy
```
Don't forget you have to use the `-var-file` option when you run terraform destroy command to delete the aws resources created with extra variable files.
```
terraform destroy -var-file fixture.tc1.tfvars
```

## Additional Resources
- [Diving into IAM Roles for Service Accounts](https://aws.amazon.com/blogs/containers/diving-into-iam-roles-for-service-accounts/)
