apiVersion: v1
kind: Service
metadata:
  name: hello-nodejs-svc
  labels:
    app: hello-nodejs
spec:
  ports:
  - port: 80
  selector:
    app: hello-nodejs
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-nodejs
  labels:
    app: hello-nodejs
spec:
  replicas: 3
  selector:
    matchLabels:
      app: hello-nodejs
  template:
    metadata:
      labels:
        app: hello-nodejs
    spec:
      containers:
      - name: hello-nodejs
        image: ${ecr_uri}
        ports:
        - containerPort: 80
