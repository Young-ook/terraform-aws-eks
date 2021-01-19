# App Mesh for Amazon EKS
[AWS App Mesh](https://aws.amazon.com/app-mesh) is a service mesh that provides application-level networking to make it easy for your services to communicate with each other across multiple types of compute infrastructure. App Mesh standardizes how your services communicate, giving you end-to-end visibility and ensuring high-availability for your applications.

## Examples
- [Learning AWS App Mesh](https://aws.amazon.com/blogs/compute/learning-aws-app-mesh/)
- [AWS App Mesh Examples](https://github.com/aws/aws-app-mesh-examples)

## Quickstart
### Setup
This is a terraform module to deploy Helm chart for App Mesh controller.
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

module "app-mesh" {
  source       = "Young-ook/eks/aws//modules/app-mesh"
  cluster_name = module.eks.cluster.name
  oidc         = module.eks.oidc
  tags         = { env = "test" }
}
```
Modify the terraform configuration file to deploy App Mesh controller. Run the terraform code to make a change on your environment.
```
terraform init
terraform apply
```

### Verify
All steps are finished, check that there are pods that are `Ready` in `appmesh-system` namespace. Ensure the `appmesh-controller` pod is generated and running:
```
$ kubectl -n appmesh-system get all
NAME                                            READY   STATUS    RESTARTS   AGE
pod/appmesh-controller-xxxxxxxxx-xxxxx          1/1     Running   0          10h

NAME                                                TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/appmesh-controller-webhook-service          ClusterIP   10.100.9.216   <none>        443/TCP   10h

NAME                                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/appmesh-controller          1/1     1            1           10h

NAME                                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/appmesh-controller-xxxxxxxxx          1         1         1       10h
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
