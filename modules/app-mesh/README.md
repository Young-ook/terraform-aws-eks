# App Mesh for Amazon EKS
[AWS App Mesh](https://aws.amazon.com/app-mesh) is a service mesh that provides application-level networking to make it easy for your services to communicate with each other across multiple types of compute infrastructure. App Mesh standardizes how your services communicate, giving you end-to-end visibility and ensuring high-availability for your applications.

## Examples
- [Quickstart Example](https://github.com/Young-ook/terraform-aws-eks/blob/main/modules/app-mesh/README.md#quickstart)
- [Learning AWS App Mesh](https://aws.amazon.com/blogs/compute/learning-aws-app-mesh/)
- [AWS App Mesh Examples](https://github.com/aws/aws-app-mesh-examples)

## Quickstart
### Setup
This is a Helm chart for App Mesh controller.
```hcl
module "eks" {
  source                     = "Young-ook/eks/aws"
  name                       = "eks"
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster.name
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster.endpoint
    token                  = data.aws_eks_cluster_auth.eks.token
    cluster_ca_certificate = base64decode(module.eks.cluster.certificate_authority.0.data)
    load_config_file       = false
  }
}

module "app-mesh" {
  source       = "Young-ook/eks/aws//modules/app-mesh"
  cluster_name = module.eks.cluster.name
  oidc         = module.eks.oidc
  tags         = { "env" = "test" }
}
```
Modify the terraform configuration file to deploy App Mesh controller. Run the terraform code to make a change on your environment.
```
terraform init
terraform apply
```

### Verify
All steps are finished, check that there are pods that are `Ready` in `appmesh-system` namespace:
Ensure the `eks-am-appmesh-controller` pod is generated and running:
```
$ kubectl -n appmesh-system get all
NAME                                            READY   STATUS    RESTARTS   AGE
pod/eks-am-appmesh-controller-db5547998-82gbl   1/1     Running   0          10h

NAME                                                TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/eks-am-appmesh-controller-webhook-service   ClusterIP   10.100.9.216   <none>        443/TCP   10h

NAME                                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/eks-am-appmesh-controller   1/1     1            1           10h

NAME                                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/eks-am-appmesh-controller-db5547998   1         1         1       10h
```
And you can list the all CRD(Custom Resource Definition)s for App Mesh integration.
```
$ kubectl get crds | grep appmesh
gatewayroutes.appmesh.k8s.aws
meshes.appmesh.k8s.aws
virtualgateways.appmesh.k8s.aws
virtualnodes.appmesh.k8s.aws
virtualrouters.appmesh.k8s.aws
virtualservices.appmesh.k8s.aws
```
