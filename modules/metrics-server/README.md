# Kubernetes Metrics Server
[Metrics Server](https://github.com/kubernetes-sigs/metrics-server) is a scalable, efficient source of container resource metrics for Kubernetes built-in autoscaling pipelines. Metrics Server collects resource metrics from Kubelets and exposes them in Kubernetes apiserver through Metrics API for use by Horizontal Pod Autoscaler and Vertical Pod Autoscaler. Metrics API can also be accessed by kubectl top, making it easier to debug autoscaling pipelines.

## Examples
- [Quickstart Example](https://github.com/Young-ook/terraform-aws-eks/blob/main/modules/metrics-server/README.md#quickstart)

## Quickstart
### Setup
This is a terraform module to deploy Helm chart for Kubernetes Metrics Server.
```hcl
module "eks" {
  source                     = "Young-ook/eks/aws"
  name                       = "eks"
}

provider "helm" {
  kubernetes {
    host                   = module.eks.helmconfig.host
    token                  = module.eks.helmconfig.token
    cluster_ca_certificate = base64decode(module.eks.helmconfig.ca)
    load_config_file       = false
  }
}

module "metrics-server" {
  source       = "Young-ook/eks/aws//modules/metrics-server"
  cluster_name = module.eks.cluster.name
  oidc         = module.eks.oidc
  tags         = { env = "test" }
}
```
Modify the terraform configuration file to deploy metrics server. Run the terraform code to make a change on your environment.
```
terraform init
terraform apply
```
