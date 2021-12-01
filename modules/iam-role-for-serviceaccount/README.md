# IAM Role for Service Account with OIDC
With [IAM roles for service accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) on Amazon EKS clusters, you can associate an IAM role with a Kubernetes service account. This module creates a single IAM role which can be assumed by trusted resources using OpenID Connect federated users. For more information about creating OpenID Connect identity provider, please visit [this](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)

## Examples
- [Quickstart](https://github.com/Young-ook/terraform-aws-eks/blob/main/modules/iam-role-for-serviceaccount/README.md#quickstart)
- [IAM Role for Service Accounts](https://github.com/Young-ook/terraform-aws-eks/blob/main/examples/irsa/)

## Quickstart
### Setup
The IAM roles for Service Accounts (IRSA) feature is available on new Amazon EKS Kubernetes version 1.14 clusters. Please make sure your EKS cluster version is 1.14 or higher to enable IAM roles for (Kubernetes) service accounts.
This is AWS documentation for [IRSA]( https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)
```hcl
module "irsa" {
  source  = "Young-ook/eks/aws//modules/iam-role-for-serviceaccount"

  namespace      = "default"
  serviceaccount = "iam-test"
  oidc_url       = module.eks.oidc.url
  oidc_arn       = module.eks.oidc.arn
  policy_arns    = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
  tags           = { "env" = "test" }
}
```
Modify the terraform configuration file to add the IRSA resources and Run the terraform code to make a change on your environment.
```
terraform init
terraform apply
```
All steps are finished, check that there is a node that is `Ready`:
```
kubectl get no
NAME                                               STATUS   ROLES    AGE   VERSION
ip-172-31-21-243.ap-northeast-2.compute.internal   Ready    <none>   15m   v1.16.13-eks-2ba888
```

### Verify
#### Create service account
Ensure the `iam-test` is created and `eks-iam-test` pod is running:
```
cat  << EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: iam-test
  namespace: default
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::{replace with your aws account}:role/irsa-test-s3-readonly
EOF
```

#### Run test application
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
      serviceAccountName: iam-test
      containers:
      - name: aws-cli
        image: amazon/aws-cli:latest
        args: ["s3", "ls"]
      restartPolicy: Never
EOF
```
