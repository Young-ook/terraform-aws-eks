# Cluster Autoscaler for Amazon EKS
[Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler) is a tool that automatically adjusts the size of a Kubernetes Cluster so that all pods have a place to run and there are no unneeded nodes when one of the following conditions is true:
* there are pods that failed to run in the cluster due to insufficient resources.
* there are nodes in the cluster that have been underutilized for an extended period of time and their pods can be placed on other existing nodes.
On AWS, Cluster Autoscaler utilizes Amazon EC2 Auto Scaling Groups to manage node groups. Cluster Autoscaler typically runs as a `Deployment` in your cluster. For more details, please check out [Cluster Autoscaler on AWS](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md)

## Examples
- [Quickstart Example](https://github.com/Young-ook/terraform-aws-eks/blob/main/modules/cluster-autoscaler/README.md#quickstart)
- [Cluster Autoscaler Exmaple](https://docs.aws.amazon.com/eks/latest/userguide/cluster-autoscaler.html)

## Quickstart
### Setup
This is a Helm chart for cluster autoscaler controller.
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

module "cluster-autoscaler" {
  source       = "Young-ook/eks/aws//modules/cluster-autoscaler"
  cluster_name = module.eks.cluster.name
  oidc         = module.eks.oidc
  tags         = { env = "test" }
}
```
Modify the terraform configuration file to deploy Cluster Autoscaler controller. Run the terraform code to make a change on your environment.
```
terraform init
terraform apply
```

### Verify
All steps are finished, check that there are pods that are `Ready` in `kube-system` namespace:
Ensure the `eks-as-aws-cluster-autoscaler-chart` pod is generated and running:

```
$ kubectl -n kube-system get po
NAME                                                   READY   STATUS    RESTARTS   AGE
aws-node-g4mh5                                         1/1     Running   0          10m
coredns-7dd7f84d9-bb9mq                                1/1     Running   0          10m
coredns-7dd7f84d9-xhpd4                                1/1     Running   0          10m
eks-alb-aws-alb-ingress-controller-6f68cb8df5-zjgxn    1/1     Running   0          10m
eks-as-aws-cluster-autoscaler-chart-59d48879c4-mwjzk   1/1     Running   0          10m
kube-proxy-q79tk                                       1/1     Running   0          10m
```
If the pod is not healthy, please try to check the log:
```
$ kubectl -n kube-system logs eks-as-aws-cluster-autoscaler-chart-59d48879c4-mwjzk
```
