[[English](README.md)] [[한국어](README.ko.md)]

# Applications
## Yelb
Yelb is an example of simple restaurant voting app using Amazon EKS and AWS App Mesh. All application computing and data storage resources are deployed on a private network. And an App Mesh proxy (also known as a sidecar proxy in Service Mesh) is also deployed alongside the application container. And AWS X-ray is a tracing system for observing the communication topology of complex distributed systems. Here is the architecture.
![aws-am-yelb-architecture](../../../images/aws-am-yelb-architecture.png)

### Deploy a service mesh example
Run kubectl from the workspace where you ran terraform:
```
kubectl apply -f yelb.yaml
```

### Access the example
#### Local Workspace
In your local workspace, connect through a proxy to access your application's endpoint.
```
kubectl -n yelb port-forward svc/yelb-ui 8080:80
```
Open `http://localhost:8080` on your web browser. This shows the application main page.

#### Cloud9
In your Cloud9 IDE, run the application.
```
kubectl -n yelb port-forward svc/yelb-ui 8080:80
```

Click **Preview** and **Preview Running Application**. This opens up a preview tab and shows the application main page.
![aws-am-yelb-screenshot](../../../images/aws-am-yelb-screenshot.png)

### Delete the application
Run kubectl:
```
kubectl delete -f yelb.yaml
```

## Game 2048
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

![aws-ec2-lbc-game-2048](../../../images/aws-ec2-lbc-game-2048.png)

### Delete the application
Run kubectl:
```
kubectl delete -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/examples/2048/2048_full.yaml
```

# Known Issues
## Dependency Violation
Make sure the game 2048 application is removed from the kubernetes cluster before deploying the infrastructure. If you skipped uninstalling the 2048 game in the previous step, you may see an error like the one below because terraform did not delete the application load balancer it created using the load balancer controller.
```
 Error: error deleting EC2 Subnet (subnet-001c9360b531a4a70): DependencyViolation: The subnet 'subnet-001c9360b531a4a70' has dependencies and cannot be deleted.
│ 	status code: 400, request id: f76a5dc7-0107-4847-a006-4c4e46be9720
╵
```
