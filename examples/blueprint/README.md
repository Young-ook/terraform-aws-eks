[[English](README.md)] [[한국어](README.ko.md)]

# EKS Bluprint
This is EKS Blueprint example helps you compose complete EKS clusters that are fully bootstrapped with the operational software that is needed to deploy and operate workloads. With this EKS Blueprint example, you describe the configuration for the desired state of your EKS environment, such as the control plane, worker nodes, and Kubernetes add-ons, as an Infrastructure as Code (IaC) template/blueprint. Once a blueprint is configured, you can use it to stamp out consistent environments across multiple AWS accounts and Regions using your automation workflow tool, such as Jenkins, CodePipeline. Also, you can use EKS Blueprint to easily bootstrap an EKS cluster with Amazon EKS add-ons as well as a wide range of popular open-source add-ons, including Prometheus, Karpenter, Nginx, Traefik, AWS Load Balancer Controller, Fluent Bit, Keda, ArgoCD, and more. EKS Blueprints also helps you implement relevant security controls needed to operate workloads from multiple teams in the same cluster.

## Setup
### Download
Download this example on your workspace
```
git clone https://github.com/Young-ook/terraform-aws-eks
cd terraform-aws-eks/examples/blueprint
```

Then you are in **blueprint** directory under your current workspace. There is an exmaple that shows how to use terraform configurations to create and manage an EKS cluster and Addon utilities on your AWS account. Check out and apply it using terraform command. If you don't have the terraform and kubernetes tools in your environment, go to the main [page](https://github.com/Young-ook/terraform-aws-eks) of this repository and follow the installation instructions before you move to the next step.

Run terraform:
```
terraform init
terraform apply
```
Also you can use the `-var-file` option for customized paramters when you run the terraform plan/apply command.
```
terraform plan -var-file fixture.tc1.tfvars
terraform apply -var-file fixture.tc1.tfvars
```

### Update kubeconfig
We need to get kubernetes config file for access the cluster that we've made using terraform. After terraform apply, you will see the bash command on the outputs. For more details, please refer to the [user guide](https://github.com/Young-ook/terraform-aws-eks#generate-kubernetes-config). 

## Kubernetes Controllers
### AWS App Mesh Controller
[AWS App Mesh](https://aws.amazon.com/app-mesh/) is a service mesh that provides application-level networking to make it easy for your services to communicate with each other across multiple types of compute infrastructure. App Mesh gives end-to-end visibility and high-availability for your applications.

#### Verify the App Mesh Controller
After all steps are finished, check all pods are *Ready* in *aws-addons* namespace by default or you've changed. Ensure the *appmesh-controller* pod is generated and running:
```
kubectl -n aws-addons get all
```
The expected output is as follows:
```
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
kubectl get crds | grep appmesh
```

The expected output is as follows:
```
gatewayroutes.appmesh.k8s.aws
meshes.appmesh.k8s.aws
virtualgateways.appmesh.k8s.aws
virtualnodes.appmesh.k8s.aws
virtualrouters.appmesh.k8s.aws
virtualservices.appmesh.k8s.aws
```

### AWS Load Balancer Controller
AWS Load Balancer Controller is a controller to help manage Elastic Load Balancers for a Kubernetes cluster.
- It satisfies Kubernetes Ingress resources by provisioning Application Load Balancers.
- It satisfies Kubernetes Service resources by provisioning Network Load Balancers.

You can load balance application traffic across pods using the AWS Application Load Balancer (ALB). To learn more, see [What is an Application Load Balancer?](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html) in the Application Load Balancers User Guide. You can share an ALB across multiple applications in your Kubernetes cluster using Ingress groups. In the past, you needed to use a separate ALB for each application. The controller automatically provisions AWS ALBs in response to Kubernetes Ingress objects. ALBs can be used with pods deployed to nodes or to AWS Fargate. You can deploy an ALB to public or private subnets.

The [AWS load balancer controller](https://github.com/kubernetes-sigs/aws-load-balancer-controller) (formerly named AWS ALB Ingress Controller) creates ALBs and the necessary supporting AWS resources whenever a Kubernetes Ingress resource is created on the cluster with the kubernetes.io/ingress.class: alb annotation. The Ingress resource configures the ALB to route HTTP or HTTPS traffic to different pods within the cluster. To ensure that your Ingress objects use the AWS load balancer controller, add the following annotation to your Kubernetes Ingress specification. For more information, see [Ingress specification](https://kubernetes-sigs.github.io/aws-load-balancer-controller/guide/ingress/spec/) on GitHub.

The AWS Load Balancer Controller makes it easy for users to take advantage of the loadbalancer management. For more details, please visit [this](https://github.com/kubernetes-sigs/aws-load-balancer-controller)

#### Verify the AWS Load Balancer Controller
All steps are finished, check that there are pods that are *Ready* in *aws-addons* namespace. Ensure the *aws-load-balancer-controller* pod is generated and running:

```
kubectl get deploy -n aws-addons aws-load-balancer-controller
```

If the pod is not healthy, please try to check in the log:
```
kubectl -n aws-addons logs aws-load-balancer-controller-7dd4ff8cb-wqq58
```

### Amazon CloudWatch Container Insights
[Amazon CloudWatch](https://aws.amazon.com/cloudwatch/) is a service that observes and monitors resources and applications on AWS, on premises, and on other clouds. Amazon CloudWatch collects and visualizes real-time logs, metrics, and event data in automated dashboards to streamline your infrastructure and application maintenance. CloudWatch automatically collects metrics for many resources, such as CPU, memory, disk, and network.

Use [Amazon CloudWatch Container Insights](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/ContainerInsights.html) to collect, aggregate, and summarize metrics and logs from your containerized applications and microservices. Container Insights is available for Amazon Elastic Container Service (Amazon ECS), Amazon Elastic Kubernetes Service (Amazon EKS), and Kubernetes platforms on Amazon EC2. Amazon ECS support includes support for Fargate. Container Insights also provides diagnostic information, such as container restart failures, to help you isolate issues and resolve them quickly. You can also set CloudWatch alarms on metrics that Container Insights collects.
![aws-cw-container-insights](../../images/aws-cw-container-insights.png)

#### Verify the CloudWatch and FluentBit agents are running on
All steps are finished, check that there are pods that are *Ready* in *aws-addons* namespace. Ensure the *aws-cloudwatch-metrics*, *aws-for-fluent-bit* pods are generated and running.

## Applications
### Yelb
#### Deploy a service mesh example
![aws-am-yelb-architecture](../../images/aws-am-yelb-architecture.png)

Run kubectl:
```
kubectl apply -f yelb.yaml
```

#### Access the example
##### Local Workspace
In your local workspace, connect through a proxy to access your application's endpoint.
```
kubectl -n yelb port-forward svc/yelb-ui 8080:80
```
Open `http://localhost:8080` on your web browser. This shows the application main page.

##### Cloud9
In your Cloud9 IDE, run the application.
```
kubectl -n yelb port-forward svc/yelb-ui 8080:80
```

Click **Preview** and **Preview Running Application**. This opens up a preview tab and shows the application main page.
![aws-am-yelb-screenshot](../../images/aws-am-yelb-screenshot.png)

#### Delete the application
Run kubectl:
```
kubectl delete -f yelb.yaml
```

### Game 2048
You can run the sample application on a cluster. Deploy the game 2048 as a sample application to verify that the AWS load balancer controller creates an AWS ALB as a result of the Ingress object.
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/examples/2048/2048_full.yaml
```

After a few minutes, verify that the Ingress resource was created with the following command. Describe ingress resource using kubectl. You will see the amazon resource name (ARN) of the generated application load balancer (ALB). Copy the address from output and open on the web browser.
```
kubectl -n game-2048 get ing
```

Output:
```
NAME           CLASS    HOSTS   ADDRESS                                                                        PORTS   AGE
ingress-2048   <none>   *       k8s-game2048-ingress2-9e5ab32c61-1003956951.ap-northeast-2.elb.amazonaws.com   80      29s
```

![aws-ec2-lbc-game-2048](../../images/aws-ec2-lbc-game-2048.png)

#### Delete the application
Run kubectl:
```
kubectl delete -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/examples/2048/2048_full.yaml
```

Make sure the game 2048 application is removed from the kubernetes cluster before deploying the infrastructure. If you skipped uninstalling the 2048 game in the previous step, you may see an error like the one below because terraform did not delete the application load balancer it created using the load balancer controller.
```
 Error: error deleting EC2 Subnet (subnet-001c9360b531a4a70): DependencyViolation: The subnet 'subnet-001c9360b531a4a70' has dependencies and cannot be deleted.
│ 	status code: 400, request id: f76a5dc7-0107-4847-a006-4c4e46be9720
╵
```

## Clean up
To destroy all infrastrcuture, run terraform:
```
terraform destroy
```

If you don't want to see a confirmation question, you can use quite option for terraform destroy command
```
terraform destroy --auto-approve
```

**[Don't forget]** You have to use the `-var-file` option when you run terraform destroy command to delete the aws resources created with extra variable files.
```
terraform destroy -var-file fixture.tc1.tfvars
```

# Additional Resources
## AWS AppMesh
- [Learning AWS App Mesh](https://aws.amazon.com/blogs/compute/learning-aws-app-mesh/)
- [AWS App Mesh Examples](https://github.com/aws/aws-app-mesh-examples)
- [Getting started with AWS App Mesh and Amazon EKS](https://aws.amazon.com/blogs/containers/getting-started-with-app-mesh-and-eks/)

## AWS Load Balancer Controller
- [Kubernetes Ingress with AWS ALB Ingress Controller](https://aws.amazon.com/blogs/opensource/kubernetes-ingress-aws-alb-ingress-controller/a)
- [AWS Load Balancer Controller](https://github.com/kubernetes-sigs/aws-load-balancer-controller)

## Amazon CloudWatch Container Insights
- [Amazon CloudWatch Container Insights for Amazon ECS](https://aws.amazon.com/blogs/mt/introducing-container-insights-for-amazon-ecs)
