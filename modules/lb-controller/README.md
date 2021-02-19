# AWS Load Balancer Controller
AWS Load Balancer Controller is a controller to help manage Elastic Load Balancers for a Kubernetes cluster.
- It satisfies Kubernetes Ingress resources by provisioning Application Load Balancers.
- It satisfies Kubernetes Service resources by provisioning Network Load Balancers.
The AWS Load Balancer Controller makes it easy for users to take advantage of the loadbalancer management. 

You can load balance application traffic across pods using the AWS Application Load Balancer (ALB). To learn more, see [What is an Application Load Balancer?](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html) in the Application Load Balancers User Guide. You can share an ALB across multiple applications in your Kubernetes cluster using Ingress groups. In the past, you needed to use a separate ALB for each application. The controller automatically provisions AWS ALBs in response to Kubernetes Ingress objects. ALBs can be used with pods deployed to nodes or to AWS Fargate. You can deploy an ALB to public or private subnets.

The [AWS load balancer controller](https://github.com/kubernetes-sigs/aws-load-balancer-controller) (formerly named AWS ALB Ingress Controller) creates ALBs and the necessary supporting AWS resources whenever a Kubernetes Ingress resource is created on the cluster with the kubernetes.io/ingress.class: alb annotation. The Ingress resource configures the ALB to route HTTP or HTTPS traffic to different pods within the cluster. To ensure that your Ingress objects use the AWS load balancer controller, add the following annotation to your Kubernetes Ingress specification. For more information, see [Ingress specification](https://kubernetes-sigs.github.io/aws-load-balancer-controller/guide/ingress/spec/) on GitHub.

## Examples
- [Quickstart Example](https://github.com/Young-ook/terraform-aws-eks/blob/main/modules/alb-ingress/README.md#quickstart)
- [Kubernetes Ingress with AWS ALB Ingress Controller](https://aws.amazon.com/blogs/opensource/kubernetes-ingress-aws-alb-ingress-controller/a)

## Quickstart
### Setup
This is a terraform module to deploy Helm chart for AWS LoadBalancer Controller.
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

module "lb-controller" {
  source       = "Young-ook/eks/aws//modules/lb-controller"
  cluster_name = module.eks.cluster.name
  oidc         = module.eks.oidc
  tags         = { env = "test" }
}
```
Modify the terraform configuration file to deploy AWS Load Balancer Controller. Run the terraform code to make a change on your environment.
```
terraform init
terraform apply
```

### Verify
All steps are finished, check that there are pods that are `Ready` in `kube-system` namespace:
Ensure the `aws-load-balancer-controller` pod is generated and running:

```sh
kubectl get deployment -n kube-system aws-load-balancer-controller
```
Output:
```
NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
aws-load-balancer-controller   2/2     2            2           84s
```
If the pod is not healthy, please try to check the log:
```sh
kubectl -n kube-system logs aws-load-balancer-controller-7dd4ff8cb-wqq58
```