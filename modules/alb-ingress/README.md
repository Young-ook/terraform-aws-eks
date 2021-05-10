# Application Load Balancer on Amazon EKS
You can load balance application traffic across pods using the AWS Application Load Balancer (ALB). To learn more, see [What is an Application Load Balancer?](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html) in the Application Load Balancers User Guide. You can share an ALB across multiple applications in your Kubernetes cluster using Ingress groups. In the past, you needed to use a separate ALB for each application. The controller automatically provisions AWS ALBs in response to Kubernetes Ingress objects. ALBs can be used with pods deployed to nodes or to AWS Fargate. You can deploy an ALB to public or private subnets.

The [AWS load balancer controller](https://github.com/kubernetes-sigs/aws-load-balancer-controller) (formerly named AWS ALB Ingress Controller) creates ALBs and the necessary supporting AWS resources whenever a Kubernetes Ingress resource is created on the cluster with the kubernetes.io/ingress.class: alb annotation. The Ingress resource configures the ALB to route HTTP or HTTPS traffic to different pods within the cluster. To ensure that your Ingress objects use the AWS load balancer controller, add the following annotation to your Kubernetes Ingress specification. For more information, see [Ingress specification](https://kubernetes-sigs.github.io/aws-load-balancer-controller/guide/ingress/spec/) on GitHub.

## Examples
- [Quickstart Example](https://github.com/Young-ook/terraform-aws-eks/blob/main/modules/alb-ingress/README.md#quickstart)
- [Kubernetes Ingress with AWS ALB Ingress Controller](https://aws.amazon.com/blogs/opensource/kubernetes-ingress-aws-alb-ingress-controller)

## Quickstart
### Setup
This is a terraform module to deploy Helm chart for ALB Ingress controller.
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

module "alb-ingress" {
  source       = "Young-ook/eks/aws//modules/alb-ingress"
  cluster_name = module.eks.cluster.name
  oidc         = module.eks.oidc
  tags         = { env = "test" }
}
```
Modify the terraform configuration file to deploy ALB Ingress controller. Run the terraform code to make a change on your environment.
```
terraform init
terraform apply
```

### Verify
All steps are finished, check that there are pods that are `Ready` in `kube-system` namespace:
Ensure the `eks-alb-aws-ingress-controller` pod is generated and running:

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
$ kubectl -n kube-system logs eks-alb-aws-alb-ingress-controller-6f68cb8df5-zjgxn
```

### Deploy sample application
You can run the sample application on a cluster. Deploy the game 2048 as a sample application to verify that the AWS load balancer controller creates an AWS ALB as a result of the Ingress object.
```
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/examples/2048/2048_full.yaml
namespace/game-2048 created
deployment.apps/deployment-2048 created
service/service-2048 created
ingress.extensions/ingress-2048 created
```
After a few minutes, verify that the Ingress resource was created with the following command.
```
$ kubectl -n game-2048 get ingress/ingress-2048
NAME           HOSTS   ADDRESS                                                                     PORTS   AGE
ingress-2048   *       81609292-game2048-ingress2-xxxxxx-yyyyyy.ap-northeast-2.elb.amazonaws.com   80      24s
```
