# Prometheus
[Prometheus](https://prometheus.io/) is an open-source systems monitoring and alerting toolkit originally built at SoundCloud. Since its inception in 2012, many companies and organizations have adopted Prometheus, and the project has a very active developer and user community. It is now a standalone open source project and maintained independently of any company. Prometheus joined the Cloud Native Computing Foundation in 2016 as the second hosted project, after Kubernetes.

## Examples
- [Deploy Promethus using Helm](https://www.eksworkshop.com/intermediate/240_monitoring/deploy-prometheus/)

## Quickstart
### Setup
This is a terraform module to deploy Helm chart for Prometheus.
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
  }
}

module "prometheus" {
  source       = "Young-ook/eks/aws//modules/prometheus"
  enabled      = true
  cluster_name = module.eks.cluster.name
  oidc         = module.eks.oidc
  tags         = { env = "test" }
  helm = {
    values = {
      "alertmanager.persistentVolume.storageClass" = "gp2"
      "server.persistentVolume.storageClass"       = "gp2"
    }
  }
}
```
Modify the terraform configuration file to deploy prometheus. Run the terraform code to make a change on your environment.
```
terraform init
terraform apply
```
