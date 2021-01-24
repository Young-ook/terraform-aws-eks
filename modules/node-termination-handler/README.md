# AWS Node Termination Handler
[AWS Node Termination Handler](https://github.com/aws/aws-node-termination-handler) is a project ensures that the Kubernetes control plane responds appropriately to events that can cause your EC2 instance to become unavailable, such as EC2 maintenance events, EC2 Spot interruptions, ASG Scale-In, ASG AZ Rebalance, and EC2 Instance Termination via the API or Console. The AWS Node Termination Handler provides a connection between termination requests from AWS to Kubernetes nodes, allowing graceful draining and termination of nodes that receive interruption notifications. The termination handler uses the Kubernetes API to initiate drain and cordon actions on a node that is targeted for termination. To learn more or get started, visit the project on [GitHub](https://github.com/aws/aws-node-termination-handler).

## Examples
- [Cost Optimization and Resilience EKS with Spot Instances](https://aws.amazon.com/blogs/compute/cost-optimization-and-resilience-eks-with-spot-instances/)

## Quickstart
### Setup
This is a terraform module to deploy Helm chart for Node Termination handler.
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

module "node-termination-handler" {
  source       = "Young-ook/eks/aws//modules/node-termination-handler"
  cluster_name = module.eks.cluster.name
  oidc         = module.eks.oidc
  tags         = { env = "test" }
}
```
Modify the terraform configuration file to deploy AWS Node Termination handler. Run the terraform code to make a change on your environment.
```
terraform init
terraform apply
```

### Verify
All steps are finished, check that the pod is `Ready` in `kube-system` namespace. Ensure the `eks-spot-aws-node-termination-hander` pod is generated and running:
```
$ kubectl -n kube-system get po
NAME                                          READY   STATUS    RESTARTS   AGE
aws-node-xxxxx                                1/1     Running   0          19h
aws-node-termination-handler-xxxxx            1/1     Running   0          19h
coredns-xxxxxxxxx-xxxxx                       1/1     Running   0          19h
coredns-xxxxxxxxx-yyyyy                       1/1     Running   0          19h
kube-proxy-xxxxx                              1/1     Running   0          19h
metrics-server-xxxxxxxxx-xxxxx                1/1     Running   0          19h
$kubectl -n kube-system get ds
NAME                                    DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
aws-node                                1         1         1       1            1           <none>                   19h
aws-node-termination-handler            1         1         1       1            1           kubernetes.io/os=linux   19h
kube-proxy                              1         1         1       1            1           <none>                   19h
```

And also, you can see the logs from pod to check working well:
```
$ kubectl -n kube-system logs -f aws-node-termination-handler-xxxxx
2021/01/17 08:14:11 ??? Trying to get token from IMDSv2
2021/01/17 08:14:11 ??? Got token from IMDSv2
2021/01/17 08:14:11 ??? Startup Metadata Retrieved metadata={"accountId":"xxxxxxxxxxxx","availabilityZone":"ap-northeast-2c","instanceId":"i-0dd84c15xxxxe411c","instanceType":"t3.large","localHostname":"ip-172-31-xxx-xxx.ap-northeast-2.compute.internal","privateIp":"172.31.xxx.xxx","publicHostname":"ec2-13-xxx-xxx-xxx.ap-northeast-2.compute.amazonaws.com","publicIp":"13.xxx.xxx.xxx","region":"ap-northeast-2"}
2021/01/17 08:14:11 ??? aws-node-termination-handler arguments:
	dry-run: false,
	node-name: ip-172-31-xxx-xxx.ap-northeast-2.compute.internal,
	metadata-url: http://169.254.169.254,
	kubernetes-service-host: 10.xxx.xxx.xxx,
	kubernetes-service-port: 443,
	delete-local-data: true,
	ignore-daemon-sets: true,
	pod-termination-grace-period: -1,
	node-termination-grace-period: 120,
	enable-scheduled-event-draining: false,
	enable-spot-interruption-draining: true,
	enable-sqs-termination-draining: false,
	enable-rebalance-monitoring: false,
	metadata-tries: 3,
	cordon-only: false,
	taint-node: false,
	json-logging: false,
	log-level: info,
	webhook-proxy: ,
	webhook-headers: <not-displayed>,
	webhook-url: ,
	webhook-template: <not-displayed>,
	uptime-from-file: ,
	enable-prometheus-server: false,
	prometheus-server-port: 9092,
	aws-region: ap-northeast-2,
	queue-url: ,
	check-asg-tag-before-draining: true,
	managed-asg-tag: aws-node-termination-handler/managed,
	aws-endpoint: ,

2021/01/17 08:14:11 ??? Started watching for interruption events
2021/01/17 08:14:11 ??? Kubernetes AWS Node Termination Handler has started successfully!
2021/01/17 08:14:11 ??? Started watching for event cancellations
2021/01/17 08:14:11 ??? Started monitoring for events event_type=SPOT_ITN
2021/01/17 09:13:59 ??? Trying to get token from IMDSv2
2021/01/17 09:13:59 ??? Got token from IMDSv2
```
