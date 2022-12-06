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

## Computing options
### AWS Fargate (Serverless)
AWS Fargate is a technology that provides on-demand, right-sized compute capacity for containers. With AWS Fargate, you no longer have to provision, configure, or scale groups of virtual machines to run containers. This removes the need to choose server types, decide when to scale your node groups, or optimize cluster packing. You can control which pods start on Fargate and how they run with Fargate profiles. Each pod running on Fargate has its own isolation boundary and does not share the underlying kernel, CPU resources, memory resources, or elastic network interface with another pod. For more information, please refer [this](https://docs.aws.amazon.com/eks/latest/userguide/fargate.html).

To run an example of serverless node groups with AWS Fargate, use the another fixture template that configures to only use AWS Fargate based instances. Edit main.tf file to remove *karpenter* from the map of helm-addons and save the file. If you don't remove it, you will get an error that the terraform configuration can't get the instance profile data from the output of the eks module. Run terraform command with fargate fixtures:
```
terraform apply -var-file fixture.fargate.tfvars
```

Then, you can deploy an example from publie resource, such as *hello-kube*, [*nginx*](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/).
For example, you can check the list of currently running farget nodes after deployment. Run kubernetes cli:
```
kubectl get no
```
```
NAME                 STATUS   ROLES    AGE     VERSION
fargate-10.0.2.59    Ready    <none>   109s    v1.17.9-eks-a84824
fargate-10.0.3.171   Ready    <none>   2m31s   v1.17.9-eks-a84824
fargate-10.0.3.80    Ready    <none>   2m49s   v1.17.9-eks-a84824
```

### AWS Graviton (Multi-Arch)
[AWS Graviton](https://aws.amazon.com/ec2/graviton/) processors are custom built by Amazon Web Services using 64-bit ARM Neoverse cores to deliver the best price performance for you cloud workloads running on Amazon EC2. The new general purpose (M6g), compute-optimized (C6g), and memory-optimized (R6g) instances deliver up to 40% better price/performance over comparable current generation x86-based instances for scale-out and Arm-based applications such as web servers, containerized microservices, caching fleets, and distributed data stores that are supported by the extensive Arm ecosystem. You can mix x86 and Arm based EC2 instances within a cluster, and easily evaluate Arm-based application in existing environments. Here is a useful [getting started](https://github.com/aws/aws-graviton-getting-started) guide on how to start to use AWS Graviton. This github repository would be good point where to start. You can find out more details about how to build, run and optimize your application for AWS Graviton processors.

To run an example of hybrid-architecture node groups with AWS Graviton, use the another fixture template that configures to only use AWS Graviton based instances. This stap will create ARM64 architecture based node groups.
```
terraform apply -var-file fixture.graviton.tfvars
```

#### CodeBuild Environment
To build an application for ARM64 architecture with AWS CodeBuild, we have to configure environment variable of the build project. The key parameters of the environment for build project are *image*, *type* and *compute type*. The image parameter is (container) image tag or image digest that identifies the Docker image to use for this build project. We use *aws/codebuild/amazonlinux2-aarch64-standard:2.0* image to build an application for ARM64 architectuer based. The type of build environment to use for related builds. In this example, *ARM_CONTAINER* is suitalbe. Be aware of that the environment type *ARM_CONTAINER* is available only in regions US East (N. Virginia), US East (Ohio), US West (Oregon), EU (Ireland), Asia Pacific (Mumbai), Asia Pacific (Tokyo), Asia Pacific (Sydney), and EU (Frankfurt). For more information about build project enviroment, please refer to [this user guide](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-codebuild-project-environment.html)
There is another important configuration for build project. We have to set compute type to *BUILD_GENERAL1_LARGE* type. Currently it is only available for *ARM_CONTAINER* environment type of CodeBuild project. Please visit [this page](https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-compute-types.html) to find out more information and for latest updates.

![aws-ecr-multi-arch-build-pipeline](../../images/aws-ecr-multi-arch-build-pipeline.png)

#### Verify Graviton instances
After provisioning of EKS cluster, you can describe nodes using kubectl and check out your node groups are running on ARM64 architecture. Amazon EKS customers can now run production workloads using Arm-based instances including the recently launched Amazon EC2 M6g, C6g, and R6g instances powered by AWS Graviton2 processors. Create an EKS cluster with a mixed architecture based node groups.
```
kubectl describe node
```
```
System Info:
  OS Image:                   Amazon Linux 2
  Operating System:           linux
  Architecture:               arm64
  Container Runtime Version:  docker://19.3.6
  Kubelet Version:            v1.17.11-eks-xxxxyy
  Kube-Proxy Version:         v1.17.11-eks-xxxxyy
```
### Amazon EC2 Spot Instances
Amazon EC2 Spot Instances let you take advantage of unused EC2 capacity in the AWS cloud. Spot Instances are available at up to a 90% discount compared to On-Demand prices; however, can be interrupted via Spot Instance interruptions, a two-minute warning before Amazon EC2 stops or terminates the instance. The AWS Node Termination Handler makes it easy for users to take advantage of the cost savings and performance boost offered by EC2 Spot Instances in their Kubernetes clusters while gracefully handling EC2 Spot Instance terminations. The AWS Node Termination Handler provides a connection between termination requests from AWS to Kubernetes nodes, allowing graceful draining and termination of nodes that receive interruption notifications. The termination handler uses the Kubernetes API to initiate drain and cordon actions on a node that is targeted for termination. For more details, please visit [this](https://github.com/Young-ook/terraform-aws-eks/blob/main/modules/node-termination-handler/)

## Applications
- [Yelb](./apps/README.md#yelb)
- [Game 2048](./apps/README.md#game-2048)
- [Nginx](./apps/README.md#nginx)
- [Hello NodeJS](./apps/README.md#hello-nodejs)

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

## Amazon EKS Add-ons
- [Metrics and traces collection using Amazon EKS add-ons for AWS Distro for OpenTelemetry (ADOT)](https://aws.amazon.com/blogs/containers/metrics-and-traces-collection-using-amazon-eks-add-ons-for-aws-distro-for-opentelemetry/)
