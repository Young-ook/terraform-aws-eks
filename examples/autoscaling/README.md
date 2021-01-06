# Autoscaling
## Setup
[This](https://github.com/Young-ook/terraform-aws-eks/blob/main/examples/complete/main.tf) is the example of terraform configuration file to create a managed EKS on your AWS account. Check out and apply it using terraform command.

Run terraform:
```
$ terraform init
$ terraform apply
```
Also you can use the `-var-file` option for customized paramters when you run the terraform plan/apply command.
```
$ terraform plan -var-file default.tfvars
$ terraform apply -var-file default.tfvars
```

## Horizontal Pod Autoscaler (HPA)
The [Horizontal Pod Autoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) automatically scales the number of Pods in a replication controller, deployment, replica set or stateful set based on observed CPU utilization.

This example requires a running Kubernetes cluster and kubectl. [Metrics server](https://github.com/kubernetes-sigs/metrics-server) monitoring needs to be deployed in the cluster to provide metrics through the [Metrics API](https://github.com/kubernetes/metrics). Horizontal Pod Autoscaler uses this API to collect metrics. To learn how to deploy the metrics-server, see the metrics-server documentation.

### PHP application
First, we will start a deployment running the image and expose it as a service.
Run the following command:
```
$ kubectl apply -f https://k8s.io/examples/application/php-apache.yaml
```

Here is the details of `php-apache.yaml` file to deploy web application. This manifest creates a simple PHP-based web server and Kubernetes service. It will listen for http requests on port 80.
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: php-apache
spec:
  selector:
    matchLabels:
      run: php-apache
  replicas: 1
  template:
    metadata:
      labels:
        run: php-apache
    spec:
      containers:
      - name: php-apache
        image: k8s.gcr.io/hpa-example
        ports:
        - containerPort: 80
        resources:
          limits:
            cpu: 500m
          requests:
            cpu: 200m
---
apiVersion: v1
kind: Service
metadata:
  name: php-apache
  labels:
    run: php-apache
spec:
  ports:
  - port: 80
  selector:
    run: php-apache
```

### Create Horizontal Pod Autoscaler
Now that the server is running, we will create the autoscaler using kubectl autoscale. The following command will create a Horizontal Pod Autoscaler that maintains between 1 and 10 replicas of the Pods controlled by the php-apache deployment we created in the first step of these instructions.
```
$ kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10
```
After a few minutes, we may check the current status of autoscaler by running:
```
$ kubectl get hpa
NAME         REFERENCE                     TARGET    MINPODS   MAXPODS   REPLICAS   AGE
php-apache   Deployment/php-apache/scale   0% / 50%  1         10        1          18s
```

### Increase load
Now, we will see how the autoscaler reacts to increased load. We will start a container, and send an infinite loop of queries to the php-apache service (please run it in a different terminal):
```
$ kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://php-apache; done"
```
Within a minute or so, we should see the higher CPU load by executing:
```
$ kubectl get hpa
NAME         REFERENCE                     TARGET      MINPODS   MAXPODS   REPLICAS   AGE
php-apache   Deployment/php-apache/scale   250% / 50%  1         10        1          3m
```
Here, CPU consumption has increased to 250% of the request. As a result, the deployment was resized to 5 replicas:
```
$ kubectl get deployment php-apache
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
php-apache   5/5     5            5           9m31s
$ kubectl get hpa
NAME         REFERENCE               TARGETS    MINPODS   MAXPODS   REPLICAS   AGE
php-apache   Deployment/php-apache   250%/50%   1         10        5          6m7s
$ kubectl get pod
NAME                          READY   STATUS    RESTARTS   AGE
php-apache-79544xxxxx-6ph8z   1/1     Running   0          56s
php-apache-79544xxxxx-mtbll   1/1     Running   0          56s
php-apache-79544xxxxx-rj8hj   1/1     Running   0          41s
php-apache-79544xxxxx-rj9p6   1/1     Running   0          6m27s
php-apache-79544xxxxx-ts5d2   1/1     Running   0          56s
```

## Clean up
Run terraform:
```
$ terraform destroy
```
Don't forget you have to use the `-var-file` option when you run terraform destroy command to delete the aws resources created with extra variable files.
```
$ terraform destroy -var-file default.tfvars
```
