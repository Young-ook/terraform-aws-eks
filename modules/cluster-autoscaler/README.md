# Cluster Autoscaler for Amazon EKS
[Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler) is a tool that automatically adjusts the size of a Kubernetes Cluster so that all pods have a place to run and there are no unneeded nodes when one of the following conditions is true:
* there are pods that failed to run in the cluster due to insufficient resources.
* there are nodes in the cluster that have been underutilized for an extended period of time and their pods can be placed on other existing nodes.
On AWS, Cluster Autoscaler utilizes Amazon EC2 Auto Scaling Groups to manage node groups. Cluster Autoscaler typically runs as a `Deployment` in your cluster. For more details, please check out [Cluster Autoscaler](https://docs.aws.amazon.com/eks/latest/userguide/cluster-autoscaler.html)

## Examples
- [Amazon EKS Autoscaling](https://github.com/Young-ook/terraform-aws-eks/blob/main/examples/autoscaling/)
- [EKS Cluster Autoscaler Setup](https://aws.amazon.com/premiumsupport/knowledge-center/eks-cluster-autoscaler-setup/)

## Quickstart
### Setup
This is a terraform module to deploy Helm chart for Cluster Autoscaler controller.
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

module "cluster-autoscaler" {
  source       = "Young-ook/eks/aws//modules/cluster-autoscaler"
  enabled      = true
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
#### Check container status
All steps are finished, check that there are pods that are `Ready` in `kube-system` namespace:
Ensure the `eks-as-aws-cluster-autoscaler-chart` pod is generated and running:

```
$ kubectl -n kube-system get po
NAME                                                   READY   STATUS    RESTARTS   AGE
aws-node-g4mh5                                         1/1     Running   0          10m
cluster-autoscaler-xxxxxxxxx-mwjzk                     1/1     Running   0          10m
kube-proxy-q79tk                                       1/1     Running   0          10m
```
If the pod is not healthy, please try to check the log:
```
$ kubectl -n kube-system logs cluster-autoscaler-xxxxxxxxx-mwjzk
```

#### Check configmap status
If users make sure that the EC2 autoscaling group(ASG) has the tags that cluster autoscaler is looking for, the users can see the latest update of cluster autoscaler. It may look like below and the users can check whether cluster autoscaler is able to recognize the ASG.
```
$ kubectl -n kube-system get cm cluster-autoscaler-status -o yaml
apiVersion: v1
data:
  status: |+
    Cluster-autoscaler status at 2021-01-08 04:04:55.644106199 +0000 UTC:
    NodeGroups:
      Name:        eks-xxxxyyyy-c03a-xxxx-1111-2dc09d308552
      Health:      Healthy (ready=2 unready=0 notStarted=0 longNotStarted=0 registered=2 longUnregistered=0 cloudProviderTarget=2 (minSize=1, maxSize=3))
                   LastProbeTime:      2021-01-08 04:04:55.643676127 +0000 UTC m=+6684.061091143
                   LastTransitionTime: 2021-01-08 02:14:17.530198588 +0000 UTC m=+45.947613652
```
If cluster autoscaler is able to recognize the ASG, the users should see the ASG name under NodeGroups section. If you don't even see NodeGroups section, it means that cluster autoscaler is still not able to autodiscover your ASG.
