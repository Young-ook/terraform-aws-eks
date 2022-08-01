# Chaos Mesh for Amazon EKS
[Chaos Mesh](https://chaos-mesh.org/docs/) is an open source cloud-native Chaos Engineering platform. It offers various types of fault simulation and has an enormous capability to orchestrate fault scenarios. Using Chaos Mesh, you can conveniently simulate various abnormalities that might occur in reality during the development, testing, and production environments and find potential problems in the system. To lower the threshold for a Chaos Engineering project, Chaos Mesh provides you with a visualization operation. You can easily design your Chaos scenarios on the Web UI and monitor the status of Chaos experiments.

## Examples
- [Chaos Testing with AWS Fault Injection Simulator and AWS CodePipeline](https://aws.amazon.com/blogs/architecture/chaos-testing-with-aws-fault-injection-simulator-and-aws-codepipeline/)

## Quickstart
### Setup
This is a terraform module to deploy Helm chart for Chaos Mesh.
```hcl
module "eks" {
  source        = "Young-ook/eks/aws"
  name          = "eks"
}

provider "helm" {
  kubernetes {
    host                   = module.eks.helmconfig.host
    token                  = module.eks.helmconfig.token
    cluster_ca_certificate = base64decode(module.eks.helmconfig.ca)
  }
}

module "app-mesh" {
  source       = "Young-ook/eks/aws//modules/chaos-mesh"
  oidc         = module.eks.oidc
  tags         = { env = "test" }
}
```
Modify your terraform configuration file to deploy Chaos Mesh on your EKS cluster. Run the terraform code to make a change on your environment.
```
terraform init
terraform apply
```

### Verify
All steps are finished, check all pods are `Ready` in `chaos-mesh` namespace by default or you've changed. To check the running status of Chaos Mesh, execute the following command:

```
kubectl get po -n chaos-mesh
```
The expected output is as follows:
```
NAME                                        READY   STATUS    RESTARTS   AGE
chaos-controller-manager-69fd5c46c8-xlqpc   3/3     Running   0          2d5h
chaos-daemon-jb8xh                          1/1     Running   0          2d5h
chaos-dashboard-98c4c5f97-tx5ds             1/1     Running   0          2d5h
```
